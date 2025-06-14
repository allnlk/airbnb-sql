import csv
import random
from datetime import datetime, timedelta

def generate_promotions_data(limit=100):
    promotions = []
    
    names = ['Spring Saver', 'Flash Frenzy', 'Loyalty Boost', 'Refer & Ride', 'Holiday Deal']
    descriptions = [
        'Enjoy discounts this spring!',
        'Limited time offer for quick bookings.',
        'Rewarding our frequent users.',
        'Refer a friend and both benefit.',
        'Celebrate the holidays with savings!'
    ]
    promo_types = ['seasonal', 'flash_sale', 'loyalty', 'referral']
    target_audiences = ['new users', 'returning users', 'VIPs', 'all users']
    channels = ['email', 'sms', 'app', 'web']  
    
    for _ in range(limit):
        start_date = datetime.now() - timedelta(days=random.randint(0, 30))
        end_date = start_date + timedelta(days=random.randint(1, 60))
        
        promotion = {
            'name': random.choice(names),
            'description': random.choice(descriptions),
            'promo_type': random.choice(promo_types),
            'discount_id': '',
            'start_date': start_date.strftime('%Y-%m-%d %H:%M:%S'),
            'end_date': end_date.strftime('%Y-%m-%d %H:%M:%S'),
            'target_audience': random.choice(target_audiences),
            'channel': random.choice(channels)  
        }
        promotions.append(promotion)
    
    return promotions

def save_to_csv(promotions, filename='promotions.csv'):
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = [
            'name', 'description', 'promo_type', 'discount_id',
            'start_date', 'end_date', 'target_audience', 'channel'
        ]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for promo in promotions:
            writer.writerow(promo)

if __name__ == '__main__':
    promotions_data = generate_promotions_data(100)
    save_to_csv(promotions_data)
    print(f"Згенеровано {len(promotions_data)} записів у файлі 'promotions.csv'")