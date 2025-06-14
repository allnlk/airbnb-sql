import csv
import random
from datetime import datetime, timedelta

def load_users(filename='users.csv'):
    """
    Завантажує користувачів із users.csv.
    Якщо немає user_id, генеруємо послідовні id (1, 2, 3, ...).
    """
    users = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for idx, row in enumerate(reader, 1):
            users.append({
                'user_id': idx,  
                'email': row.get('email', ''),
                'bio': row.get('bio', ''),
                'country': row.get('country', '')
            })
    return users

def generate_giftcards(users, limit=1000):
    giftcards = []
    valid_statuses = ['Active', 'Used', 'Expired']
    for _ in range(min(limit, len(users))):
        user = random.choice(users)
        code = f"GC-{random.randint(10000000, 99999999)}-{random.randint(1000,9999)}"
        balance = round(random.uniform(10, 510), 2)
        issue_date = datetime.now()
        expiry_days = random.randint(1, 365)
        expiry_date = issue_date + timedelta(days=expiry_days)
        status = random.choice(valid_statuses).strip()  # !!!

        giftcards.append({
            'code': code,
            'user_id': user['user_id'],
            'balance': f"{balance:.2f}",
            'issue_date': issue_date.strftime('%Y-%m-%d %H:%M:%S'),
            'expiry_date': expiry_date.strftime('%Y-%m-%d'),
            'status': status
        })
    return giftcards

def save_giftcards_to_csv(giftcards, filename='giftcards.csv'):
    fieldnames = ['code', 'user_id', 'balance', 'issue_date', 'expiry_date', 'status']
    with open(filename, 'w', newline='', encoding='utf-8') as f: # !!!
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for card in giftcards:
            writer.writerow(card)



def save_giftcards_to_csv(giftcards, filename='giftcards.csv'):
    fieldnames = ['code', 'user_id', 'balance', 'issue_date', 'expiry_date', 'status']
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for card in giftcards:
            writer.writerow(card)

if __name__ == '__main__':
    users = load_users('users.csv')
    giftcards = generate_giftcards(users, limit=1000)
    save_giftcards_to_csv(giftcards)
    print(f"Згенеровано {len(giftcards)} записів у 'giftcards.csv'")
