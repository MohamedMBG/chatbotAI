#!/usr/bin/env python3
"""
Multi-Personality Intimate AI Bot - PRODUCT VERSION
Enhanced storytelling bot with personality system for hotwife/cuckold market
"""

import json
import requests
import time
import logging
import random
import os
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

# Import personality system
from personalities import PersonalityManager

# Configuration - USE ENVIRONMENT VARIABLES FOR SECURITY
TELEGRAM_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN', 'YOUR_BOT_TOKEN_HERE')
TELEGRAM_API = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}"
OLLAMA_URL = "http://localhost:11434"
MODEL_NAME = "llama3.1:70b"

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class MultiPersonalityIntimateBot:
    def __init__(self):
        # Initialize personality system
        self.personality_manager = PersonalityManager()
        
        # Bot state management
        self.training_data = self.load_training_data()
        self.conversation_history = {}
        self.user_modes = {}  # Track user preferences for response length
        self.pending_confirmations = {}  # Track users waiting for confirmation responses
        
        # Setup TF-IDF for similarity matching
        self.inputs = [pair.get('you', '') for pair in self.training_data]
        self.outputs = [pair.get('her', '') for pair in self.training_data]
        
        self.vectorizer = TfidfVectorizer(max_features=1000, stop_words=None)
        try:
            self.tfidf_matrix = self.vectorizer.fit_transform(self.inputs)
        except:
            logger.error("Failed to setup TF-IDF")
        
        logger.info(f"🎭 Multi-Personality Bot - Loaded {len(self.training_data)} training examples")
        logger.info(f"📖 PERSONALITY SYSTEM - Hotwife/Cuckold Market Ready!")
        
    def load_training_data(self):
        """Load training data - personality-specific data will be loaded separately"""
        training_file = os.getenv('TRAINING_DATA_PATH', 'training_data.json')
        try:
            with open(training_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            logger.error(f"Failed to load training data from {training_file}")
            return [{"you": "sample input", "her": "sample response"}]
    
    def detect_response_mode(self, user_input, user_id):
        """Detect what kind of response the user wants - enhanced with personality awareness"""
        
        # Get current personality
        personality = self.personality_manager.get_personality(user_id)
        
        # Check user's explicit mode setting
        user_mode = self.user_modes.get(user_id, 'auto')
        
        # Continue triggers - should send more story messages
        continue_triggers = [
            'continúa', 'continua', 'sigue', 'continue', 'más', 'more',
            'keep going', 'no pares', 'quiero más', 'me gusta sigue',
            'me excita', 'exita', 'amor sigue', 'sigue amor'
        ]
        
        # Personality-aware storytelling triggers
        story_triggers = [
            'cuéntame', 'imagina', 'fantasía', 'historia', 'relato',
            'tell me', 'imagine', 'story', 'describe', 'what would happen',
            'cómo sería', 'qué pasaría', 'me gusta cuando', 'invitas', 'invita',
            'la próxima vez', 'busquemos', 'salgamos', 'amigo', 'tercero'
        ]
        
        # Add personality-specific triggers
        if hasattr(personality, 'scenario_types'):
            story_triggers.extend(['date', 'bull', 'cuck', 'hotwife', 'size'])
        
        # Long response triggers
        long_triggers = [
            'explícame', 'dime cómo', 'háblame de', 'quiero saber',
            'me encanta', 'describe', 'detalle'
        ]
        
        input_lower = user_input.lower()
        
        # Force modes
        if user_mode == 'story':
            return 'storytelling'
        elif user_mode == 'long':
            return 'long'
        elif user_mode == 'short':
            return 'short'
        
        # Auto-detection with personality awareness
        if any(trigger in input_lower for trigger in continue_triggers):
            return 'continue_story'  # Special mode for continuing stories
        elif any(trigger in input_lower for trigger in story_triggers):
            return 'storytelling'
        elif any(trigger in input_lower for trigger in long_triggers):
            return 'long'
        elif len(user_input) > 50:  # Longer input usually wants longer response
            return 'long'
        else:
            return 'short'
    
    def create_personality_enhanced_story_start(self, user_input, user_id):
        """Create story start using current personality"""
        personality = self.personality_manager.get_personality(user_id)
        
        # Try to detect scenario type from input
        input_lower = user_input.lower()
        scenario_type = 'general'
        
        if any(word in input_lower for word in ['date', 'dating', 'out', 'tonight']):
            scenario_type = 'date_planning'
        elif any(word in input_lower for word in ['bull', 'boyfriend', 'man', 'guy']):
            scenario_type = 'bull_selection'
        elif any(word in input_lower for word in ['big', 'size', 'bigger', 'huge']):
            scenario_type = 'size_comparison'
        
        # Get personality-specific confirmation
        confirmation = personality.get_confirmation_style(scenario_type)
        
        # Add personality flair
        enhanced_confirmation = personality.add_personality_flair(confirmation)
        
        return enhanced_confirmation
    
    def create_personality_enhanced_responses(self, user_input, user_id, mode):
        """Generate responses enhanced by current personality"""
        personality = self.personality_manager.get_personality(user_id)
        
        # Get base response from training data
        base_response = self.find_best_training_response(user_input, mode)
        
        # Apply personality modifications
        enhanced_response = personality.get_response_modifiers(base_response)
        
        # Add personality flair
        final_response = personality.add_personality_flair(enhanced_response)
        
        return final_response
    
    def find_best_training_response(self, user_input, mode='short'):
        """Find the best authentic response from training data"""
        try:
            query_vec = self.vectorizer.transform([user_input])
            similarities = cosine_similarity(query_vec, self.tfidf_matrix)[0]
            
            # Get top matches based on mode
            top_count = {'storytelling': 8, 'long': 5, 'short': 3}.get(mode, 3)
            
            top_indices = similarities.argsort()[-top_count:][::-1]
            good_matches = [(i, similarities[i]) for i in top_indices if similarities[i] > 0.05]
            
            if good_matches:
                chosen_idx = random.choice([idx for idx, sim in good_matches[:3]])
                return self.outputs[chosen_idx]
            else:
                return self.get_fallback_response(mode)
                    
        except Exception as e:
            logger.error(f"Training matching error: {e}")
            return self.get_fallback_response(mode)
    
    def get_fallback_response(self, mode):
        """Get fallback response based on mode"""
        fallbacks = {
            'storytelling': "Tell me more about what you'd like to hear...",
            'long': "That's interesting. Let me think about that...",
            'short': "Mmm... tell me more"
        }
        return fallbacks.get(mode, "I'm listening...")
    
    def handle_commands(self, text, user_id):
        """Handle bot commands including personality commands"""
        
        # Handle personality system commands first
        if text.startswith('/personality') or text.startswith('/date_') or text.startswith('/bull_') or text.startswith('/size_') or text.startswith('/after_') or text.startswith('/shopping') or text.startswith('/teasing'):
            command_parts = text.split()
            command = command_parts[0]
            args = command_parts[1:] if len(command_parts) > 1 else None
            
            response = self.personality_manager.handle_personality_command(user_id, command, args)
            if response:
                return response
        
        # Handle standard bot commands
        if text == '/short':
            self.user_modes[user_id] = 'short'
            return "🔥 Modo corto activado - respuestas directas y concisas"
        elif text == '/long':
            self.user_modes[user_id] = 'long'
            return "📖 Modo largo activado - respuestas más detalladas"
        elif text == '/story':
            self.user_modes[user_id] = 'story'
            return "🎭 Modo historia activado - fantasías y relatos largos"
        elif text == '/auto':
            self.user_modes[user_id] = 'auto'
            return "🎯 Modo automático activado - detección inteligente"
        elif text == '/help':
            personality = self.personality_manager.get_personality(user_id)
            personality_commands = personality.get_market_specific_commands()
            
            help_text = f"""🎭 Multi-Personality Intimate Bot
Current: {personality.get_personality_name()}

📖 Response Modes:
/short - Respuestas cortas y directas
/long - Respuestas largas y detalladas  
/story - Modo fantasía/relato largo
/auto - Detección automática (default)

🎭 Personality Commands:"""
            
            for cmd, desc in personality_commands.items():
                help_text += f"\n{cmd} - {desc}"
            
            return help_text
        
        return None
    
    def generate_and_send_response(self, user_input, chat_id, user_id):
        """Generate response with personality system and send in chunks"""
        
        # Check if user has pending confirmation
        if user_id in self.pending_confirmations:
            # User is responding to a confirmation request
            original_request = self.pending_confirmations[user_id]
            
            # Generate multiple story responses based on their confirmation with personality
            story_responses = self.create_personality_story_progression(original_request, user_input, user_id)
            
            # Clear pending confirmation
            del self.pending_confirmations[user_id]
            
            logger.info(f"📋 Processing confirmation response: {user_input[:30]}...")
            logger.info(f"📖 Will send {len(story_responses)} personality-enhanced story messages")
            
            # Send all story responses sequentially
            return self.send_sequential_story_responses(chat_id, story_responses)
            
        else:
            # Normal flow - detect mode
            mode = self.detect_response_mode(user_input, user_id)
            logger.info(f"🎯 Detected mode: {mode}")
            
            if mode == 'continue_story':
                # User wants to continue the story - send more story messages directly
                logger.info(f"🔄 Continue story detected - generating personality-enhanced continuation")
                
                # Generate varied continuation story responses with personality
                story_responses = self.create_personality_continuation_story(user_input, user_id)
                
                logger.info(f"📖 Will send {len(story_responses)} personality continuation messages")
                
                # Send all story responses sequentially
                return self.send_sequential_story_responses(chat_id, story_responses)
                
            elif mode == 'storytelling':
                # For storytelling, send confirmation request first
                response = self.create_personality_enhanced_story_start(user_input, user_id)
                
                # Mark user as having pending confirmation
                self.pending_confirmations[user_id] = user_input
                
                logger.info(f"❓ Sending personality-enhanced confirmation request, awaiting response")
                
            else:
                # Normal response for short/long modes with personality enhancement
                response = self.create_personality_enhanced_responses(user_input, user_id, mode)
        
        # Start initial typing
        initial_typing = {'storytelling': 4, 'long': 3, 'short': 2}.get(mode, 2)
        
        self.send_typing_action(chat_id)
        time.sleep(initial_typing)
        
        # Send response in natural chunks
        success = self.send_message_chunks(chat_id, response, mode)
        
        return response, success
    
    def create_personality_story_progression(self, user_input, confirmation_response, user_id):
        """Create story progression with personality enhancement"""
        # This would be implemented similar to the original but with personality integration
        personality = self.personality_manager.get_personality(user_id)
        
        # Generate base story responses (simplified for demo)
        num_responses = random.randint(3, 13)
        story_responses = []
        
        for i in range(num_responses):
            base_response = self.find_best_training_response(user_input, 'storytelling')
            enhanced_response = personality.get_response_modifiers(base_response)
            final_response = personality.add_personality_flair(enhanced_response)
            story_responses.append(final_response)
        
        return story_responses
    
    def create_personality_continuation_story(self, user_input, user_id):
        """Create continuation story with personality"""
        # Similar implementation with personality enhancement
        personality = self.personality_manager.get_personality(user_id)
        
        num_responses = random.randint(3, 13)
        story_responses = []
        
        for i in range(num_responses):
            base_response = self.find_best_training_response(user_input, 'storytelling')
            enhanced_response = personality.get_response_modifiers(base_response)
            final_response = personality.add_personality_flair(enhanced_response)
            story_responses.append(final_response)
        
        return story_responses
    
    # ... REST OF BOT IMPLEMENTATION (send_message_chunks, etc.) ...
    # This is a framework showing personality integration
    
    def send_typing_action(self, chat_id):
        """Send typing indicator"""
        try:
            requests.post(f"{TELEGRAM_API}/sendChatAction", {
                'chat_id': chat_id,
                'action': 'typing'
            }, timeout=5)
        except:
            pass
    
    def send_message_chunks(self, chat_id, text, mode):
        """Send message (simplified for demo)"""
        try:
            requests.post(f"{TELEGRAM_API}/sendMessage", {
                'chat_id': chat_id,
                'text': text
            }, timeout=10)
            return True
        except:
            return False
    
    def send_sequential_story_responses(self, chat_id, story_responses):
        """Send multiple responses sequentially (simplified for demo)"""
        for response in story_responses:
            self.send_typing_action(chat_id)
            time.sleep(random.uniform(2, 5))
            self.send_message_chunks(chat_id, response, 'storytelling')
            time.sleep(1)
        return " | ".join(story_responses), True

    def run(self):
        """Main bot loop - simplified for demo"""
        logger.info("🚀 Multi-Personality Bot starting")
        logger.info("🎭 Personality System: Ready for hotwife/cuckold market")
        logger.info("🔗 Commands: /personality, /date_planning, /bull_selection, etc.")
        
        # Main loop would go here...
        pass

if __name__ == "__main__":
    # Check for required environment variables
    if TELEGRAM_TOKEN == 'YOUR_BOT_TOKEN_HERE':
        logger.error("❌ Please set TELEGRAM_BOT_TOKEN environment variable")
        exit(1)
    
    bot = MultiPersonalityIntimateBot()
    bot.run()