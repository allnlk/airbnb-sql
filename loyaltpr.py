import csv
import random
from datetime import datetime, timedelta

def load_users(filename='users.csv'):
    users = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for idx, row in enumerate(reader, 1):  # idx починається з 1 — user_id
            users.append({
                'user_id': idx,
                'email': row['email'],
                'bio': row['bio'],
                'country': row['country']
            })
    return users

def generate_loyalty_programs(users):
    tiers = ['Bronze', 'Silver', 'Gold', 'Platinum']
    loyalty_data = []

    for user in users:
        join_days_ago = random.randint(1, 1000)
        last_activity_days_ago = random.randint(0, 30)
        join_date = (datetime.now() - timedelta(days=join_days_ago)).date()
        last_activity_date = (datetime.now() - timedelta(days=last_activity_days_ago)).date()

        loyalty_data.append({
            'user_id': user['user_id'],
            'points_balance': random.randint(0, 1000),
            'current_tier': random.choice(tiers),
            'join_date': join_date.strftime('%Y-%m-%d'),
            'last_activity_date': last_activity_date.strftime('%Y-%m-%d')
        })
    return loyalty_data

def save_loyalty_to_csv(loyalty_data, filename='loyalty_programs.csv'):
    fieldnames = ['user_id', 'points_balance', 'current_tier', 'join_date', 'last_activity_date']
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for row in loyalty_data:
            writer.writerow(row)

if __name__ == '__main__':
    users = load_users('users.csv')
    loyalty_programs = generate_loyalty_programs(users)
    save_loyalty_to_csv(loyalty_programs)
    print(f"Згенеровано {len(loyalty_programs)} записів у 'loyalty_programs.csv'")
