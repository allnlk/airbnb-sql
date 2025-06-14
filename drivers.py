import random
import csv
from datetime import date, timedelta

# Функція для завантаження користувачів з CSV файлу users.csv (email, bio, country)
def load_users(filename):
    users = []
    with open(filename, 'r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        user_id = 1  # Будемо генерувати id самі, якщо його немає у файлі
        for row in reader:
            email = row.get('email')
            country = row.get('country')

            if email and country:
                users.append({'id': user_id, 'email': email, 'country': country})
                user_id += 1
            else:
                print(f"Пропущено рядок через відсутність email або country: {row}")
    return users

def generate_license_number(used_numbers):
    letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
    while True:
        part1 = random.choice(letters)
        part2 = random.randint(100000, 999999)
        part3 = random.choice(letters)
        number = f"{part1}{part2}{part3}"
        if number not in used_numbers:
            return number

def generate_license_expiry():
    days_to_add = random.randint(1, 3650)
    expiry_date = date.today() + timedelta(days=days_to_add)
    return expiry_date.strftime('%Y-%m-%d')

def generate_verified():
    return '1' if random.random() > 0.7 else '0'

# Згенерувати дані для таблиці Drivers
def generate_drivers(users, limit=500):
    drivers = []
    used_license_numbers = set()
    for user in random.sample(users, min(limit, len(users))):  # Вибираємо випадкових юзерів
        user_id = user['id']  # Беремо згенерований нами ID

        license_number = generate_license_number(used_license_numbers)
        used_license_numbers.add(license_number)  # Запам'ятовуємо використаний номер

        license_country = user['country']
        license_expiry = generate_license_expiry()
        verified = generate_verified()

        drivers.append((user_id, license_number, license_country, license_expiry, verified))

    return drivers

# Зберегти дані у CSV файл
def save_drivers_to_csv(drivers, filename='drivers.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['user_id', 'license_number', 'license_country', 'license_expiry', 'verified'])
        writer.writerows(drivers)

# Завантажуємо дані з users.csv
users = load_users('users.csv')
drivers_data = generate_drivers(users, limit=500)
save_drivers_to_csv(drivers_data)

print(f"Згенеровано файл drivers.csv з {len(drivers_data)} записами.")
