import csv
import random
from datetime import datetime

def load_users(filename='users.csv'):
    users = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for idx, row in enumerate(reader, 1):  # user_id починається з 1
            users.append({
                'user_id': idx,
                'email': row.get('email', ''),
                'bio': row.get('bio', ''),
                'country': row.get('country', '')
            })
    return users

def generate_notifications(users, limit=1000):
    notification_types = ['Booking', 'Payment', 'Incident', 'Promotion', 'System']
    notifications = []

    for _ in range(min(limit, len(users))):
        user = random.choice(users)

        # Вибір notification_type
        notification_type = random.choice(notification_types)

        # Вибір message залежно від випадкового числа
        r = random.random()
        if r < 0.2:
            message = 'Your booking has been confirmed for the upcoming stay.'
        elif r < 0.4:
            amount = round(10 + random.random() * 990, 2)
            message = f'Your payment of ${amount} has been successfully processed.'
        elif r < 0.6:
            message = 'An incident was reported involving your recent booking.'
        elif r < 0.8:
            message = 'Check out our latest promotion and get discounts on your next service.'
        else:
            message = 'System maintenance notice: Service may be temporarily unavailable.'

        # Вибір статусу
        status = random.choice(['Unread', 'Read', 'Archived'])

        notifications.append({
            'user_id': user['user_id'],
            'notification_type': notification_type,
            'message': message,
            'status': status,
            'created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        })

    return notifications

def save_notifications_to_csv(notifications, filename='notifications.csv'):
    fieldnames = ['user_id', 'notification_type', 'message', 'status', 'created_at']
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for notification in notifications:
            writer.writerow(notification)

if __name__ == '__main__':
    users = load_users('users.csv')
    notifications = generate_notifications(users, limit=1000)
    save_notifications_to_csv(notifications)
    print(f"Згенеровано {len(notifications)} записів у 'notifications.csv'")
