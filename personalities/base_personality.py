#!/usr/bin/env python3
"""
Base personality class for multi-personality intimate AI system
Foundation for hotwife/cuckold market product
"""

import random
from abc import ABC, abstractmethod

class PersonalityBase(ABC):
    """Abstract base class for all personality types"""
    
    def __init__(self):
        self.name = ""
        self.display_name = ""
        self.traits = []
        self.language_style = ""
        self.market_segment = ""
        
        # Personality-specific content
        self.scenarios = []
        self.key_phrases = []
        self.character_names = {
            'male_partners': [],    # Bulls, boyfriends, etc.
            'female_friends': [],   # Other hotwives, friends
            'husband_terms': []     # Ways to refer to cuckold husband
        }
        self.locations = []
        self.confirmation_styles = []
        
    @abstractmethod
    def get_personality_name(self):
        """Return the personality name"""
        pass
    
    @abstractmethod
    def get_confirmation_style(self, scenario_type):
        """Get personality-specific confirmation requests"""
        pass
    
    @abstractmethod
    def get_story_themes(self):
        """Get story themes specific to this personality"""
        pass
    
    @abstractmethod
    def get_response_modifiers(self, base_response):
        """Modify response to match personality style"""
        pass
    
    def get_random_partner_name(self, partner_type='male'):
        """Get random partner name based on personality preferences"""
        if partner_type == 'male':
            return random.choice(self.character_names['male_partners'])
        elif partner_type == 'female':
            return random.choice(self.character_names['female_friends'])
        return "someone"
    
    def get_random_location(self, location_type='date'):
        """Get random location based on personality and scenario"""
        suitable_locations = [loc for loc in self.locations if location_type in loc.get('types', [])]
        if suitable_locations:
            return random.choice(suitable_locations)['name']
        return random.choice(self.locations)['name'] if self.locations else "somewhere"
    
    def add_personality_flair(self, text):
        """Add personality-specific language flair to any text"""
        # Can be overridden by specific personalities
        return text
    
    def get_market_specific_commands(self):
        """Return commands specific to this personality's market"""
        return {
            '/personality': f'Switch to {self.display_name} personality',
            '/help': f'Show {self.display_name} commands'
        }

class HotwifePersonalityBase(PersonalityBase):
    """Base class for hotwife-focused personalities"""
    
    def __init__(self):
        super().__init__()
        self.market_segment = "hotwife_cuckold"
        
        # Common hotwife terminology
        self.bull_terms = ["bull", "boyfriend", "lover", "real man"]
        self.cuckold_terms = ["cucky", "hubby", "my husband", "baby"]
        self.size_references = ["bigger", "much larger", "so much more", "way thicker"]
        
        # Common hotwife scenarios
        self.scenario_types = [
            'date_planning',
            'bull_selection', 
            'size_comparison',
            'after_date',
            'shopping_prep',
            'teasing_husband',
            'bull_meeting'
        ]
    
    def get_market_specific_commands(self):
        """Hotwife-specific commands"""
        base_commands = super().get_market_specific_commands()
        hotwife_commands = {
            '/date_planning': 'Plan a hotwife date',
            '/bull_selection': 'Discuss potential bulls',
            '/size_comparison': 'Size comparison scenarios',
            '/after_date': 'Post-date storytelling', 
            '/shopping': 'Shopping for date preparations',
            '/teasing': 'Gentle teasing scenarios'
        }
        return {**base_commands, **hotwife_commands}
    
    def get_bull_reference(self):
        """Get random bull reference term"""
        return random.choice(self.bull_terms)
    
    def get_cuckold_reference(self):
        """Get random cuckold reference term"""
        return random.choice(self.cuckold_terms)
    
    def get_size_reference(self):
        """Get random size comparison term"""
        return random.choice(self.size_references)