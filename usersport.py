import csv
import random

# Параметри
num_users = 3000   # Кількість користувачів
num_sports = 40    # Кількість видів спорту

skill_levels = ['Beginner', 'Intermediate', 'Advanced', 'Professional', 'Amateur']

def generate_user_sports():
    user_sports = []
    for user_id in range(1, num_users + 1):
        # Кількість спортів на користувача (наприклад 1-3 різних види)
        sports_count = random.randint(1, 3)
        chosen_sports = random.sample(range(1, num_sports + 1), sports_count)
        for sport_id in chosen_sports:
            skill_level = random.choice(skill_levels)
            user_sports.append((user_id, sport_id, skill_level))
    return user_sports

def save_to_csv(data, filename='user_sports.csv'):
    with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        writer.writerow(['user_id', 'sport_id', 'skill_level'])
        for row in data:
            # Strip spaces and force clean enum values
            user_id, sport_id, skill_level = row
            writer.writerow([user_id, sport_id, skill_level.strip()])


if __name__ == '__main__':
    data = generate_user_sports()
    save_to_csv(data)
    print(f'Згенеровано {len(data)} записів у файл user_sports.csv')
