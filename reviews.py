import random
import csv
from datetime import datetime, timedelta

def load_user_ids(filename):
    """Load user data from a CSV file"""
    users = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=1):
            users.append({
                'id': i,  
                'email': row['email']
            })
    return users

def load_room_ids(filename):
    """Load room data from a CSV file"""
    rooms = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=1):
            rooms.append({
                'id': i,  
                'owner_email': row.get('owner_email', '') 
            })
    return rooms

def load_car_ids(filename):
    """Load car data from a CSV file and assign IDs manually"""
    cars = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=1):
            cars.append({
                'id': i,  # Assign a unique ID manually
                'email': row['email']
            })
    return cars



def generate_rating():
    """Generate a random rating between 1 and 5"""
    return random.randint(1, 5)

def generate_comment(rating):
    """Generate a comment based on rating"""
    comments = {
        1: ['Terrible experience', 'Not recommended', 'Worst ever', 'Avoid this', 'Very disappointed'],
        2: ['Could be better', 'Below expectations', 'Needs improvement', 'Not great', 'Mediocre'],
        3: ['Average experience', 'It was okay', 'Nothing special', 'Met expectations', 'Decent'],
        4: ['Good experience', 'Very satisfied', 'Would recommend', 'Enjoyed it', 'Great service'],
        5: ['Excellent!', 'Perfect experience', 'Absolutely amazing', 'Best ever', 'Exceeded expectations']
    }
    return random.choice(comments[rating])

def generate_review_date():
    """Generate a random review date within the last year"""
    days_back = random.randint(0, 365)
    review_date = datetime.now() - timedelta(days=days_back)
    return review_date.strftime('%Y-%m-%d %H:%M:%S')

def generate_reviews(users, rooms, cars, limit=100):
    """Generate review data ensuring valid relationships"""
    reviews = []
    
    for _ in range(limit):
        user = random.choice(users)
        

        review_type = random.choice(['room', 'car'])
        
        if review_type == 'room' and rooms:
            
            available_rooms = [r for r in rooms if r['owner_email'] != user['email']]
            if available_rooms:
                room = random.choice(available_rooms)
                reviews.append({
                    'user_id': user['id'],
                    'room_id': room['id'],
                    'car_id': None,
                    'rating': generate_rating(),
                    'comment': generate_comment(generate_rating()),
                    'review_date': generate_review_date()
                })
        elif cars:
            
            available_cars = [c for c in cars if c['email'] != user['email']]
            if available_cars:
                car = random.choice(available_cars)
                reviews.append({
                    'user_id': user['id'],
                    'room_id': None,
                    'car_id': car['id'],
                    'rating': generate_rating(),
                    'comment': generate_comment(generate_rating()),
                    'review_date': generate_review_date()
                })
    
    return reviews

def save_reviews_to_csv(reviews, filename='reviews.csv'):
    """Save reviews to a CSV file"""
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        fieldnames = ['user_id', 'room_id', 'car_id', 'rating', 'comment', 'review_date']
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        for review in reviews:
            review_data = {k: ('\\N' if v is None else v) for k, v in review.items()}
            writer.writerow(review_data)


if __name__ == '__main__':

    users = load_user_ids(r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\users.csv')
    rooms = load_room_ids('rooms.csv')
    cars = load_car_ids('cars.csv')
    
    reviews_data = generate_reviews(users, rooms, cars, limit=100)
    
    save_reviews_to_csv(reviews_data)

    print(f"CSV file 'reviews.csv' generated with {len(reviews_data)} records.")
