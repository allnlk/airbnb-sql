import random
import csv

first_names = [
    'john', 'mike', 'david', 'alex', 'chris',
    'emma', 'sarah', 'lisa', 'anna', 'olga',
    'ivan', 'petro', 'andrii', 'serhii', 'vitalii',
    'maria', 'natalia', 'oksana', 'tetiana', 'yulia',
    'ben', 'samuel', 'arthur', 'george', 'henry',
    'elizabeth', 'victoria', 'alice', 'grace', 'charlotte',
    'akihiro', 'kenji', 'hiroki', 'takashi', 'daiki',
    'sakura', 'ayumi', 'yumi', 'akari', 'hana',
    'carlos', 'javier', 'diego', 'manuel', 'fernando',
    'isabela', 'sofia', 'valentina', 'camila', 'lucia'
]

last_names = [
    'smith', 'johnson', 'williams', 'brown', 'jones',
    'miller', 'davis', 'wilson', 'anderson', 'thomas',
    'kovalenko', 'petrenko', 'sydorenko', 'bondarenko', 'kravchenko',
    'melnyk', 'shevchenko', 'boyko', 'tkachenko', 'kovalchuk',
    'taylor', 'martin', 'white', 'adams', 'jackson',
    'wright', 'king', 'scott', 'nelson', 'baker',
    'tanaka', 'yamamoto', 'sato', 'ito', 'watanabe',
    'santos', 'silva', 'pereira', 'oliveira', 'rodrigues',
    'gomez', 'fernandez', 'lopez', 'martinez', 'gonzalez'
]

domains = [
    'gmail.com', 'yahoo.com', 'outlook.com', 'icloud.com', 'protonmail.com',
    'ukr.net', 'i.ua', 'meta.ua', 'mail.com', 'hotmail.com',
    'aol.com', 'zoho.com', 'yandex.ru', 'gmx.com', 'mail.fr'
]

separators = ['', '.', '_', '-']

countries = ['US', 'UA', 'CA', 'GB', 'DE', 'FR', 'JP', 'IN', 'BR', 'AU', 'ES', 'IT', 'CN', 'MX', 'KR']

professions = [
    'software engineer', 'graphic designer', 'teacher', 'doctor', 'nurse',
    'photographer', 'writer', 'musician', 'chef', 'mechanic',
    'driver', 'pilot', 'scientist', 'artist', 'lawyer',
    'student', 'manager', 'consultant', 'developer', 'engineer'
]

hobbies = [
    'hiking', 'reading', 'traveling', 'cooking', 'painting',
    'gaming', 'swimming', 'cycling', 'running', 'yoga',
    'photography', 'gardening', 'dancing', 'writing', 'fishing'
]

def generate_email(index):
    first = random.choice(first_names)
    sep = random.choice(separators)
    last = random.choice(last_names)
    number = random.randint(1, 999)
    domain = random.choice(domains)
    email = f"{first}{sep}{last}{number}{index}@{domain}".lower()
    return email

def generate_bio():
    prof = random.choice(professions)
    hobby = random.choice(hobbies)
    bio = f"{prof.title()} who loves {hobby}."
    return bio

def generate_users(num_users):
    users = []
    emails_set = set()
    for i in range(1, num_users + 1):
        while True:
            email = generate_email(i)
            if email not in emails_set:
                emails_set.add(email)
                break
        bio = generate_bio()
        country = random.choice(countries)
        users.append((email, bio, country))
    return users

def save_users_to_csv(users, filename="users.csv"):
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['email', 'bio', 'country'])  
        csv_writer.writerows(users)

num_users = 10000
users_data = generate_users(num_users)
save_users_to_csv(users_data)

