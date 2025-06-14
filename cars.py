import random
import csv

def load_emails_from_file(filename):
    emails = []
    with open(filename, 'r', encoding='utf-8') as csvfile:
        csv_reader = csv.reader(csvfile)
        next(csv_reader)  
        for row in csv_reader:
            email = row[0]  
            emails.append(email)
    return emails

brands = ['Toyota', 'Honda', 'Ford', 'Chevrolet', 'BMW', 'Audi', 'Hyundai', 'Kia', 'Nissan', 'Volkswagen']
models = ['Corolla', 'Civic', 'F-150', 'Impala', '3 Series', 'A4', 'Elantra', 'Sportage', 'Altima', 'Golf']

def generate_car():
    brand = random.choice(brands)
    model = random.choice(models)
    year = random.randint(2000, 2023)
    return brand, model, year

def generate_cars(num_cars, emails):
    if num_cars > len(emails):
        raise ValueError("Кількість машин більша за кількість унікальних email")
    selected_emails = random.sample(emails, num_cars)
    cars = []
    for email in selected_emails:
        brand, model, year = generate_car()
        cars.append((email, brand, model, year))
    return cars

def save_cars_to_csv(cars, filename="cars.csv"):
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['email', 'brand', 'model', 'year'])
        writer.writerows(cars)

# ✅ Correct path to users.csv
emails = load_emails_from_file(r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\users.csv')

num_cars = 3000
cars_data = generate_cars(num_cars, emails)
save_cars_to_csv(cars_data)

print(f"CSV файл 'cars.csv' згенеровано з {num_cars} записами.")
