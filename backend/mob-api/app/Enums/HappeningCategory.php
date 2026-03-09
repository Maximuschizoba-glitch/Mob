<?php

namespace App\Enums;

enum HappeningCategory: string
{
    case PARTY_NIGHTLIFE = 'party_nightlife';
    case FOOD_DRINKS = 'food_drinks';
    case HANGOUTS_SOCIAL = 'hangouts_social';
    case MUSIC_PERFORMANCE = 'music_performance';
    case GAMES_ACTIVITIES = 'games_activities';
    case ART_CULTURE = 'art_culture';
    case STUDY_WORK = 'study_work';
    case POPUPS_STREET = 'popups_street';
}
