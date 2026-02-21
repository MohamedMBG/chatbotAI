"""
Multi-Personality System for Intimate AI Bot
Supporting hotwife/cuckold market segments
"""

from .base_personality import PersonalityBase, HotwifePersonalityBase
from .hotwife_dominant import HotwifeDominantPersonality

__all__ = [
    'PersonalityBase',
    'HotwifePersonalityBase', 
    'HotwifeDominantPersonality',
    'PersonalityManager'
]

class PersonalityManager:
    """Manages multiple personalities and switching between them"""
    
    def __init__(self):
        self.personalities = {}
        self.current_personality = {}  # per user_id
        self.default_personality = "sophia"
        
        # Register available personalities
        self._register_personalities()
    
    def _register_personalities(self):
        """Register all available personality classes"""
        self.personalities = {
            "sophia": {
                "class": HotwifeDominantPersonality,
                "name": "Sophia - Dominant Hotwife",
                "market": "hotwife_cuckold",
                "description": "Confident, assertive, sexually dominant hotwife",
                "premium": False
            },
            # Future personalities will be added here
            # "emma": {
            #     "class": HotwifeLoving Personality,
            #     "name": "Emma - Loving Cuckoldress", 
            #     "market": "hotwife_cuckold",
            #     "description": "Affectionate but sexually dominant",
            #     "premium": True
            # }
        }
    
    def get_personality(self, user_id):
        """Get current personality instance for user"""
        if user_id not in self.current_personality:
            self.current_personality[user_id] = self.personalities[self.default_personality]["class"]()
        return self.current_personality[user_id]
    
    def switch_personality(self, user_id, personality_name):
        """Switch user to different personality"""
        if personality_name in self.personalities:
            personality_class = self.personalities[personality_name]["class"]
            self.current_personality[user_id] = personality_class()
            return True, f"Switched to {self.personalities[personality_name]['name']}"
        else:
            available = ", ".join(self.personalities.keys())
            return False, f"Unknown personality. Available: {available}"
    
    def get_available_personalities(self, user_subscription="basic"):
        """Get list of personalities available to user based on subscription"""
        available = {}
        for name, config in self.personalities.items():
            if not config.get("premium", False) or user_subscription == "premium":
                available[name] = {
                    "name": config["name"],
                    "description": config["description"], 
                    "market": config["market"],
                    "premium": config.get("premium", False)
                }
        return available
    
    def get_personality_commands(self, user_id):
        """Get commands available for current personality"""
        personality = self.get_personality(user_id)
        return personality.get_market_specific_commands()
    
    def handle_personality_command(self, user_id, command, args=None):
        """Handle personality-specific commands"""
        personality = self.get_personality(user_id)
        
        if command == "/personality":
            if args and len(args) > 0:
                new_personality = args[0].lower()
                success, message = self.switch_personality(user_id, new_personality)
                return message
            else:
                available = self.get_available_personalities()
                personality_list = "\n".join([
                    f"• {name}: {config['name']}" 
                    for name, config in available.items()
                ])
                current = personality.get_personality_name()
                return f"Current: {current}\n\nAvailable personalities:\n{personality_list}\n\nUse: /personality <name>"
        
        elif command in ["/date_planning", "/bull_selection", "/size_comparison", "/after_date", "/shopping", "/teasing"]:
            scenario_type = command.replace("/", "").replace("_", "_")
            return personality.get_confirmation_style(scenario_type)
        
        return None  # Command not handled by personality system