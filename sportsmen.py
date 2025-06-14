import random
import csv
import datetime

# Data pools
first_names = [
    'john', 'mike', 'david', 'alex', 'chris', 
    'emma', 'sarah', 'lisa', 'anna', 'olga',
    'ivan', 'petro', 'andrii', 'serhii', 'vitalii',
    'maria', 'natalia', 'oksana', 'tetiana', 'yulia',
    'lebron', 'serena', 'roger', 'lionel', 'cristiano',
    'naomi', 'usain', 'michael', 'kobe', 'tiger'
]

last_names = [
    'smith', 'johnson', 'williams', 'brown', 'jones',
    'miller', 'davis', 'wilson', 'anderson', 'thomas',
    'kovalenko', 'petrenko', 'sydorenko', 'bondarenko', 'kravchenko',
    'melnyk', 'shevchenko', 'boyko', 'tkachenko', 'kovalchuk',
    'james', 'williams', 'federer', 'messi', 'ronaldo',
    'osaka', 'bolt', 'phelps', 'bryant', 'woods'
]

separators = ['', '.', '_', '-', '.', '_', '-', '.', '_', '-']

domains = [
    'gmail.com', 'yahoo.com', 'outlook.com', 'icloud.com', 'protonmail.com',
    'ukr.net', 'i.ua', 'meta.ua', 'mail.com', 'hotmail.com'
]

prefixes = ['Professional', 'Elite', 'Olympic', 'National', 'Retired']

sports = [
    'football', 'basketball', 'tennis', 'swimming', 'athletics',
    'gymnastics', 'boxing', 'volleyball', 'hockey', 'cycling',
    'golf', 'baseball', 'rugby', 'cricket', 'skiing',
    'snowboarding', 'surfing', 'martial arts', 'table tennis', 'badminton'
]

countries_full = [
    'the US', 'Germany', 'Canada', 'India', 'Brazil',
    'the UK', 'France', 'Japan', 'Australia', 'Ukraine',
    'Spain', 'Italy', 'China', 'South Korea', 'Argentina'
]

countries_short = ['US', 'UA', 'CA', 'GB', 'DE', 'FR', 'JP', 'IN', 'BR', 'AU', 'ES', 'IT', 'CN', 'KR', 'AR']

specializations = [
    'offensive strategies', 'defensive techniques', 'speed training', 'endurance conditioning',
    'technical skills', 'tactical awareness', 'mental preparation', 'nutrition planning',
    'recovery methods', 'equipment optimization'
]

current_teams = [
    'a premier league club', 'a national team', 'a college team', 'a local club', 'an Olympic team',
    'a professional franchise', 'a youth academy', 'a regional squad', 'an international league', 'a championship team'
]

former_teams = [
    'FC Barcelona', 'LA Lakers', 'New York Yankees', 'Manchester United', 'Real Madrid',
    'Golden State Warriors', 'Chicago Bulls', 'All Blacks', 'Indian Cricket Team', 'Boston Red Sox'
]

achievements = [
    'Olympic medalist', 'world champion', 'national title holder', 'MVP award winner',
    'record breaker', 'all-star player', 'hall of famer', 'golden boot winner', 
    'championship winner', 'tournament champion'
]

def generate_email(row_num):
    first = random.choice(first_names)
    sep = random.choice(separators)
    last = random.choice(last_names)
    number = random.randint(0, 999)
    timestamp = int(datetime.datetime.now().timestamp())
    domain = random.choice(domains)
    
    return f"{first}{sep}{last}{number}{timestamp}_{row_num}@{domain}".lower()

def generate_bio():
    prefix = random.choice(prefixes)
    sport = random.choice(sports)
    country = random.choice(countries_full)

    
    bio = f"{prefix} {sport} player representing {country}."

    rand_val = random.random()
    if rand_val < 0.3:
        specialization = random.choice(specializations)
        bio += f" Specializes in {specialization}."
    elif rand_val < 0.6:
        team = random.choice(current_teams)
        bio += f" Currently playing for {team}."
    else:
        team = random.choice(former_teams)
        achievement = random.choice(achievements)
        bio += f" Former {achievement} with {team}."

    return bio

def generate_users(num_users):
    users = []
    for i in range(1, num_users + 1):
        email = generate_email(i)
        bio = generate_bio()
        country = random.choice(countries_short)
        users.append((email, bio, country))
    return users

def save_to_csv(users, filename="sportsmen.csv"):
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['email', 'bio', 'country'])
        writer.writerows(users)

num_users = 10000
sportsmen_users = generate_users(num_users)
save_to_csv(sportsmen_users)

print(f"Successfully generated {num_users} sportsmen profiles in sportsmen.csv")
