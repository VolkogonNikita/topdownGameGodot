import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.distributions import Categorical

#абсолютные пути
BASE_DIR = "D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/"
DATA_FILE = os.path.join(BASE_DIR, "greeting.txt")
WEIGHTS_PATH = os.path.join(BASE_DIR, "seq2seq_weights.pth")
INPUT_FILE = "D:/учёба/диплом/test/test_voice_recognition/output.txt"
OUTPUT_FILE = "D:/учёба/диплом/test/test_voice_recognition/output.txt"

# Параметры
learning_rate = 0.01
epochs = 300
max_lines = 100
max_len = 50
embedding_dim = 64
hidden_size = 128
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# Загрузка данных
def load_data(file_path, max_lines=None):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    if max_lines:
        lines = lines[:max_lines]
    data = []
    for line in lines:
        parts = line.strip().split('\t')
        if len(parts) >= 2:
            data.append((parts[0].strip(), parts[1].strip()))
    return data


# Dataset
class Dataset:
    def __init__(self, path, max_len, max_lines=None):
        self.pairs = load_data(path, max_lines)
        self.max_len = max_len
        self.input_vocab = {'<pad>': 0, '<sos>': 1, '<eos>': 2, '<unk>': 3}
        self.output_vocab = {'<pad>': 0, '<sos>': 1, '<eos>': 2, '<unk>': 3}
        self.build_vocab()

    def build_vocab(self):
        for en, ru in self.pairs:
            for c in en:
                if c not in self.input_vocab:
                    self.input_vocab[c] = len(self.input_vocab)
            for c in ru:
                if c not in self.output_vocab:
                    self.output_vocab[c] = len(self.output_vocab)
        self.input_size = len(self.input_vocab)
        self.output_size = len(self.output_vocab)

    def encode(self, text, vocab, add_eos=True):
        tokens = [vocab['<sos>']] + [vocab.get(c, vocab['<unk>']) for c in text]
        if add_eos:
            tokens.append(vocab['<eos>'])
        tokens += [vocab['<pad>']] * (self.max_len - len(tokens))
        return tokens[:self.max_len]

    def decode(self, indices, vocab):
        inv_vocab = {v: k for k, v in vocab.items()}
        result = []
        for idx in indices:
            if idx == vocab['<eos>']:
                break
            if idx not in (vocab['<sos>'], vocab['<pad>']):
                result.append(inv_vocab.get(idx, ''))
        return ''.join(result)


# Encoder
class Encoder(nn.Module):
    def __init__(self, input_size, emb_size, hidden_size):
        super().__init__()
        self.embedding = nn.Embedding(input_size, emb_size)
        self.rnn = nn.GRU(emb_size, hidden_size, batch_first=True)

    def forward(self, x):
        # x shape: (batch_size, seq_len)
        x = self.embedding(x)  # shape: (batch_size, seq_len, emb_size)
        _, hidden = self.rnn(x)  # hidden shape: (num_layers, batch_size, hidden_size)
        return hidden


# Decoder
class Decoder(nn.Module):
    def __init__(self, output_size, emb_size, hidden_size):
        super().__init__()
        self.embedding = nn.Embedding(output_size, emb_size)
        self.rnn = nn.GRU(emb_size, hidden_size, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x, hidden):
        # x shape: (batch_size)
        # hidden shape: (num_layers, batch_size, hidden_size)

        x = self.embedding(x)  # shape: (batch_size, emb_size)
        x = x.unsqueeze(1)  # shape: (batch_size, 1, emb_size)

        output, hidden = self.rnn(x, hidden)  # output shape: (batch_size, 1, hidden_size)
        output = self.fc(output.squeeze(1))  # shape: (batch_size, output_size)

        return output, hidden


# Seq2Seq модель
class Seq2Seq(nn.Module):
    def __init__(self, encoder, decoder, sos_idx, max_len):
        super().__init__()
        self.encoder = encoder
        self.decoder = decoder
        self.sos_idx = sos_idx
        self.max_len = max_len

    def forward(self, src, trg):
        # src shape: (batch_size, src_seq_len)
        # trg shape: (batch_size, trg_seq_len)

        batch_size = src.size(0)
        hidden = self.encoder(src)

        # Первый вход для декодера - <sos> токен
        input = trg[:, 0]  # shape: (batch_size)
        outputs = []

        for t in range(1, trg.size(1)):
            out, hidden = self.decoder(input, hidden)
            outputs.append(out.unsqueeze(1))
            # Teacher forcing - используем настоящий следующий токен
            input = trg[:, t]

        return torch.cat(outputs, dim=1)  # shape: (batch_size, trg_seq_len-1, output_size)

    def translate(self, src, trg_vocab, temperature=1.0):
        # src shape: (seq_len,) - убираем batch dimension если он есть
        if src.dim() > 1:
            src = src.squeeze(0)

        # Добавляем batch dimension
        src = src.unsqueeze(0)  # shape: (1, seq_len)

        hidden = self.encoder(src)  # shape: (num_layers, 1, hidden_size)

        input = torch.tensor([self.sos_idx], dtype=torch.long).to(device)  # shape: (1,)
        outputs = []

        for _ in range(self.max_len):
            out, hidden = self.decoder(input, hidden)

            # Применяем температуру
            logits = out / temperature
            probs = torch.softmax(logits, dim=-1)
            distribution = Categorical(probs)
            pred = distribution.sample()  # shape: (1,)

            input = pred
            outputs.append(pred.item())

            if pred.item() == trg_vocab['<eos>']:
                break

        return outputs

    def save_weights(self, path):
        torch.save(self.state_dict(), path)

    def load_weights(self, path):
        if os.path.exists(path):
            self.load_state_dict(torch.load(path, map_location=device))
            print(f"Загружено: {path}")
        else:
            print(f"Файл {path} не найден.")


# Обучение
def train(model, dataset, X, Y, lr, epochs):
    model.to(device)
    optimizer = optim.Adam(model.parameters(), lr=lr)
    criterion = nn.CrossEntropyLoss(ignore_index=dataset.output_vocab['<pad>'])

    X_tensor = torch.tensor(X, dtype=torch.long).to(device)
    Y_tensor = torch.tensor(Y, dtype=torch.long).to(device)

    losses = []

    for epoch in range(epochs):
        model.train()
        optimizer.zero_grad()
        output = model(X_tensor, Y_tensor)

        # output shape: (batch_size, trg_seq_len-1, output_size)
        # target shape: (batch_size, trg_seq_len-1)
        loss = criterion(output.reshape(-1, output.size(-1)), Y_tensor[:, 1:].reshape(-1))
        loss.backward()
        optimizer.step()
        losses.append(loss.item())

        if epoch % 10 == 0:
            print(f"Эпоха {epoch}, Потери: {loss.item():.4f}")

def save_result_to_file(result, output_file = "D:/учёба/диплом/test/test_voice_recognition/output.txt"):
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(result)

# Главная функция
if __name__ == "__main__":
    path = "D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/greeting.txt"
    dataset = Dataset(path, max_len, max_lines)
    X = [dataset.encode(en, dataset.input_vocab) for en, _ in dataset.pairs]
    Y = [dataset.encode(ru, dataset.output_vocab) for _, ru in dataset.pairs]

    encoder = Encoder(dataset.input_size, embedding_dim, hidden_size)
    decoder = Decoder(dataset.output_size, embedding_dim, hidden_size)
    model = Seq2Seq(encoder, decoder, dataset.output_vocab['<sos>'], max_len)

    weights_path = "D:/учёба/3 курс/6 сем/ЕЯИИС/еяиис2/seq2seq_weights.pth"
    #action = input("train/load: ").strip()
    #if action == "train":
        #train(model, dataset, X, Y, learning_rate, epochs)
        #model.save_weights(weights_path)
    #elif action == "load":
     #   model.load_weights(weights_path)
    #else:
     #   exit("Неверный ввод")

    #while True:
        #text = input("Введите фразу на английском (или 'exit'): ").strip()
        #if text.lower() == 'exit':
         #   break


    model.load_weights(weights_path)
    file = open("D:/учёба/диплом/test/test_voice_recognition/output.txt", "r", encoding="utf-8")
    text = file.read()
    file.close()

    encoded = torch.tensor(dataset.encode(text, dataset.input_vocab), dtype=torch.long).to(device)
    output_ids = model.translate(encoded, dataset.output_vocab)
    #print("Перевод:", dataset.decode(output_ids, dataset.output_vocab))

    save_result_to_file(dataset.decode(output_ids, dataset.output_vocab),"D:/учёба/диплом/test/test_voice_recognition/output.txt")