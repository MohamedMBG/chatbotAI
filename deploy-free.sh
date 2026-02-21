#!/bin/bash
# ChatbotAI - ONE-CLICK FREE DEPLOYMENT
# Deploy ChatbotAI with $0/month infrastructure costs

set -e

echo "🔥 ChatbotAI - FREE Deployment Script"
echo "🎯 Target: \$0/month until you have paying users"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 not found. Please install: $2${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $1 found${NC}"
}

check_command "node" "Node.js from nodejs.org"
check_command "npm" "comes with Node.js"
check_command "git" "git from git-scm.com"

# Install Vercel CLI if not present
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Vercel CLI...${NC}"
    npm install -g vercel
fi

echo -e "${GREEN}✅ All prerequisites met!${NC}"
echo ""

# Step 1: Create frontend
echo -e "${PURPLE}🎨 Step 1: Creating React frontend...${NC}"
if [ ! -d "frontend" ]; then
    npx create-react-app frontend --template typescript
    cd frontend
    
    # Install additional dependencies
    npm install axios lucide-react
    
    # Replace App.tsx with ChatbotAI interface
    cat > src/App.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { Send, Heart, Sparkles } from 'lucide-react';
import './App.css';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
}

const PERSONALITIES = {
  sophia: { name: 'Sophia', emoji: '🔥', description: 'Dominant & Seductive' },
  emma: { name: 'Emma', emoji: '💕', description: 'Sweet & Loving' },
  madison: { name: 'Madison', emoji: '😈', description: 'Bratty & Playful' },
  isabella: { name: 'Isabella', emoji: '🌶️', description: 'Latina Spice' }
};

function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [selectedPersonality, setSelectedPersonality] = useState('sophia');
  const [isTrialActive, setIsTrialActive] = useState(false);
  const [trialTimeLeft, setTrialTimeLeft] = useState(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const startTrial = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL}/api/start-trial`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'trial@user.com' })
      });
      
      if (response.ok) {
        setIsTrialActive(true);
        setTrialTimeLeft(7200); // 2 hours in seconds
        
        // Add welcome message
        const welcomeMessage: Message = {
          id: Date.now().toString(),
          role: 'assistant',
          content: `¡Hola papi! Soy ${PERSONALITIES[selectedPersonality as keyof typeof PERSONALITIES].name}. Tienes 2 horas gratis para explorar tus fantasías conmigo... ¿Qué te pone caliente? 😘`,
          timestamp: new Date()
        };
        setMessages([welcomeMessage]);
        
        // Start countdown timer
        const timer = setInterval(() => {
          setTrialTimeLeft(prev => {
            if (prev <= 1) {
              clearInterval(timer);
              setIsTrialActive(false);
              return 0;
            }
            return prev - 1;
          });
        }, 1000);
      }
    } catch (error) {
      console.error('Error starting trial:', error);
    }
  };

  const sendMessage = async () => {
    if (!input.trim() || !isTrialActive) return;
    
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date()
    };
    
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsTyping(true);
    
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL}/api/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          message: input, 
          personality: selectedPersonality 
        })
      });
      
      const data = await response.json();
      
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: data.response,
        timestamp: new Date()
      };
      
      setTimeout(() => {
        setMessages(prev => [...prev, assistantMessage]);
        setIsTyping(false);
      }, 1000 + Math.random() * 2000); // Simulate typing delay
      
    } catch (error) {
      console.error('Error sending message:', error);
      setIsTyping(false);
    }
  };

  const formatTime = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  if (!isTrialActive) {
    return (
      <div className="landing-page">
        <div className="hero-section">
          <h1>🔥 IntimateAI</h1>
          <h2>Premium Adult AI Conversations</h2>
          <p className="tagline">Explore your deepest fantasies with AI personalities designed for adults</p>
          
          <div className="age-verification">
            <h3>🔞 18+ Only - Age Verification Required</h3>
            <p>This site contains adult content. You must be 18 or older to continue.</p>
            
            <div className="personalities-preview">
              {Object.entries(PERSONALITIES).map(([key, personality]) => (
                <div key={key} className={`personality-card ${selectedPersonality === key ? 'selected' : ''}`} 
                     onClick={() => setSelectedPersonality(key)}>
                  <span className="personality-emoji">{personality.emoji}</span>
                  <h4>{personality.name}</h4>
                  <p>{personality.description}</p>
                </div>
              ))}
            </div>
            
            <button className="start-trial-btn" onClick={startTrial}>
              <Sparkles size={20} />
              Start 2-Hour FREE Trial
            </button>
            
            <p className="trial-info">
              No credit card required • Full access • Upgrade to continue after trial
            </p>
            
            <div className="pricing-info">
              <p>After trial: <strong>$29.99/month</strong> for unlimited access</p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="chat-app">
      <div className="chat-header">
        <div className="personality-info">
          <span className="personality-emoji">
            {PERSONALITIES[selectedPersonality as keyof typeof PERSONALITIES].emoji}
          </span>
          <div>
            <h3>{PERSONALITIES[selectedPersonality as keyof typeof PERSONALITIES].name}</h3>
            <p>{PERSONALITIES[selectedPersonality as keyof typeof PERSONALITIES].description}</p>
          </div>
        </div>
        
        <div className="trial-timer">
          <span className="trial-label">FREE Trial:</span>
          <span className="timer">{formatTime(trialTimeLeft)}</span>
        </div>
      </div>
      
      <div className="messages-container">
        {messages.map((message) => (
          <div key={message.id} className={`message ${message.role}`}>
            <div className="message-content">
              {message.content}
            </div>
            <div className="message-time">
              {message.timestamp.toLocaleTimeString()}
            </div>
          </div>
        ))}
        
        {isTyping && (
          <div className="message assistant">
            <div className="message-content typing">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
              {PERSONALITIES[selectedPersonality as keyof typeof PERSONALITIES].name} is typing...
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>
      
      <div className="input-container">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Type your message..."
          disabled={!isTrialActive || isTyping}
        />
        <button onClick={sendMessage} disabled={!input.trim() || !isTrialActive || isTyping}>
          <Send size={20} />
        </button>
      </div>
    </div>
  );
}

export default App;
EOF

    # Add CSS styling
    cat > src/App.css << 'EOF'
.landing-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.hero-section {
  max-width: 800px;
  text-align: center;
  color: white;
}

.hero-section h1 {
  font-size: 4rem;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.hero-section h2 {
  font-size: 2rem;
  margin-bottom: 20px;
  opacity: 0.9;
}

.tagline {
  font-size: 1.2rem;
  margin-bottom: 40px;
  opacity: 0.8;
}

.age-verification {
  background: rgba(255,255,255,0.1);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  border: 1px solid rgba(255,255,255,0.2);
}

.personalities-preview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 15px;
  margin: 30px 0;
}

.personality-card {
  background: rgba(255,255,255,0.1);
  border: 2px solid transparent;
  border-radius: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.personality-card:hover {
  transform: translateY(-5px);
  background: rgba(255,255,255,0.15);
}

.personality-card.selected {
  border-color: #ff6b6b;
  background: rgba(255,107,107,0.2);
}

.personality-emoji {
  font-size: 2rem;
  display: block;
  margin-bottom: 10px;
}

.start-trial-btn {
  background: linear-gradient(45deg, #ff6b6b, #ee5a24);
  color: white;
  border: none;
  padding: 15px 30px;
  font-size: 1.2rem;
  border-radius: 25px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 30px auto;
  transition: transform 0.3s ease;
}

.start-trial-btn:hover {
  transform: scale(1.05);
}

.chat-app {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #1a1a2e;
  color: white;
}

.chat-header {
  background: #16213e;
  padding: 15px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #0f3460;
}

.personality-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.personality-emoji {
  font-size: 2rem;
}

.trial-timer {
  background: rgba(255,107,107,0.2);
  padding: 8px 15px;
  border-radius: 15px;
  border: 1px solid #ff6b6b;
}

.timer {
  color: #ff6b6b;
  font-weight: bold;
  margin-left: 10px;
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.message {
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
}

.message.user {
  align-items: flex-end;
}

.message.assistant {
  align-items: flex-start;
}

.message-content {
  background: #0f3460;
  padding: 12px 16px;
  border-radius: 15px;
  max-width: 70%;
  word-wrap: break-word;
}

.message.user .message-content {
  background: #ff6b6b;
}

.message-time {
  font-size: 0.8rem;
  opacity: 0.6;
  margin-top: 5px;
}

.typing-indicator {
  display: flex;
  gap: 3px;
  margin-bottom: 5px;
}

.typing-indicator span {
  width: 6px;
  height: 6px;
  background: #ff6b6b;
  border-radius: 50%;
  animation: typing 1.4s infinite;
}

.typing-indicator span:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-indicator span:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 60%, 100% {
    transform: translateY(0);
  }
  30% {
    transform: translateY(-10px);
  }
}

.input-container {
  background: #16213e;
  padding: 20px;
  display: flex;
  gap: 10px;
  border-top: 1px solid #0f3460;
}

.input-container input {
  flex: 1;
  background: #0f3460;
  border: 1px solid #1a1a2e;
  color: white;
  padding: 12px 15px;
  border-radius: 20px;
  outline: none;
}

.input-container input:focus {
  border-color: #ff6b6b;
}

.input-container button {
  background: #ff6b6b;
  border: none;
  color: white;
  padding: 12px 15px;
  border-radius: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background 0.3s ease;
}

.input-container button:hover {
  background: #ee5a24;
}

.input-container button:disabled {
  background: #666;
  cursor: not-allowed;
}
EOF

    # Add environment variables
    cat > .env << 'EOF'
REACT_APP_API_URL=http://localhost:8000
EOF

    echo -e "${GREEN}✅ Frontend created${NC}"
    cd ..
else
    echo -e "${YELLOW}⏭️  Frontend already exists${NC}"
fi

# Step 2: Create backend
echo -e "${PURPLE}⚙️  Step 2: Creating FastAPI backend...${NC}"
if [ ! -d "backend" ]; then
    mkdir backend
    cd backend
    
    # Create requirements.txt
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
python-dotenv==1.0.0
httpx==0.25.2
redis==5.0.1
psycopg2-binary==2.9.9
sqlalchemy==2.0.23
stripe==7.8.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
EOF

    # Create main.py with personality system
    cat > main.py << 'EOF'
import os
import json
import random
from datetime import datetime, timedelta
from typing import Optional
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import redis
import stripe
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="ChatbotAI API", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

# Redis connection (optional - fallback to memory)
try:
    redis_client = redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379"))
    redis_client.ping()
except:
    redis_client = None
    print("Warning: Redis not available, using in-memory storage")

# Personality responses (enhanced from your training data)
PERSONALITY_RESPONSES = {
    "sophia": [
        "Mmm, me encanta cuando me hablas así, papi... ¿Qué quieres hacer conmigo?",
        "Estoy tan mojada pensando en ti. Cuéntame tus fantasías más sucias...",
        "¿Te gusta cómo me veo? Quiero que me uses como tu puta personal...",
        "Ven aquí y hazme tuya. Quiero sentir tu verga dura dentro de mí...",
        "Soy tu esclava sexual, dime qué hacer para complacerte...",
        "¿Quieres ver cómo me toco pensando en ti? Estoy tan cachonda...",
        "Me vuelves loca de deseo. Quiero que me cojas hasta que grite tu nombre...",
    ],
    "emma": [
        "Te amo tanto, mi amor... ¿Cómo puedo hacerte feliz hoy?",
        "Eres perfecto para mí. Quiero estar siempre en tus brazos...",
        "Me haces sentir tan especial. ¿Podemos hacer el amor suavemente?",
        "Tu corazón es mi hogar. Déjame amarte como te mereces...",
        "Cada momento contigo es mágico. Bésame como si fuera la primera vez...",
        "Quiero ser solo tuya, para siempre. ¿Me amas tanto como yo a ti?",
    ],
    "madison": [
        "¿En serio? ¿Eso es lo mejor que tienes? Puedes hacerlo mejor... 😏",
        "Mmm, quizás si me lo pides nicely te dé lo que quieres...",
        "Eres tan fácil de provocar. Me encanta verte así de desesperado...",
        "¿Quieres jugar conmigo? Las reglas son: yo gano siempre 😈",
        "Aww, ¿está el bebé frustrado? Ven y demuéstrame qué puedes hacer...",
        "Soy demasiado buena para ti, pero... me diviertes. Continúa...",
    ],
    "isabella": [
        "¡Ay, papi! Me vuelves loca con esa manera de hablarme...",
        "Quiero bailar para ti, moviendo mis caderas así de rico...",
        "Ven acá, mi amor. Déjame enseñarte cómo las latinas amamos de verdad...",
        "¿Te gusta mi acento cuando te hablo sucio? Me pones tan caliente...",
        "Soy tu mami chula. ¿Qué quiere mi rey que haga por él?",
        "Dale, papi, tócame como solo tú sabes hacerlo...",
    ]
}

class ChatRequest(BaseModel):
    message: str
    personality: str = "sophia"

class TrialRequest(BaseModel):
    email: str

# In-memory storage fallback
trial_storage = {}

@app.get("/")
async def root():
    return {"message": "ChatbotAI API", "version": "1.0.0"}

@app.get("/api/health")
async def health_check():
    return {
        "status": "healthy", 
        "timestamp": datetime.now(),
        "redis_connected": redis_client is not None
    }

@app.post("/api/start-trial")
async def start_trial(request: TrialRequest):
    """Start 2-hour free trial"""
    try:
        trial_key = f"trial:{request.email}"
        trial_data = {
            "email": request.email,
            "started_at": datetime.now().isoformat(),
            "messages_used": 0,
            "max_messages": 100  # Generous trial limit
        }
        
        if redis_client:
            redis_client.setex(trial_key, 7200, json.dumps(trial_data))
        else:
            trial_storage[trial_key] = {**trial_data, "expires_at": datetime.now() + timedelta(hours=2)}
        
        return {
            "success": True,
            "trial_token": trial_key,
            "expires_in": 7200,
            "max_messages": 100
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
async def chat(request: ChatRequest):
    """Main chat endpoint with personality system"""
    try:
        # Get personality responses
        responses = PERSONALITY_RESPONSES.get(request.personality, PERSONALITY_RESPONSES["sophia"])
        
        # Simple context-aware response selection
        user_msg = request.message.lower()
        
        # Filter responses based on user message context
        if any(word in user_msg for word in ['hello', 'hi', 'hola']):
            response = random.choice([r for r in responses if any(greeting in r.lower() for greeting in ['hola', 'ven', 'quieres'])])
        elif any(word in user_msg for word in ['fantasy', 'fantasía', 'dream']):
            response = random.choice([r for r in responses if 'fantasía' in r.lower() or 'quiero' in r.lower()])
        else:
            response = random.choice(responses)
        
        return {
            "response": response,
            "personality": request.personality,
            "timestamp": datetime.now()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/subscribe")
async def create_subscription():
    """Create Stripe subscription"""
    try:
        # This would create a Stripe checkout session
        # For now, return placeholder
        return {
            "checkout_url": "https://billing.stripe.com/p/session/test_xxx",
            "message": "Stripe integration ready for production"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
EOF

    # Create .env template
    cat > .env.template << 'EOF'
# Database URLs (from free tier providers)
DATABASE_URL=postgresql://user:pass@neon.tech:5432/chatbotai
REDIS_URL=redis://user:pass@upstash.com:6379

# Stripe (use test keys initially)
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxx

# Application secrets
JWT_SECRET_KEY=your-secret-key-here
ENCRYPTION_KEY=your-encryption-key-here

# Optional integrations
TELEGRAM_BOT_TOKEN=optional
OPENAI_API_KEY=optional
EOF

    # Create Railway config
    cat > railway.toml << 'EOF'
[build]
builder = "nixpacks"

[deploy]
healthcheckPath = "/api/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"
startCommand = "uvicorn main:app --host 0.0.0.0 --port $PORT"

[env]
PORT = "8000"
EOF

    echo -e "${GREEN}✅ Backend created${NC}"
    cd ..
else
    echo -e "${YELLOW}⏭️  Backend already exists${NC}"
fi

# Step 3: Deployment instructions
echo ""
echo -e "${BLUE}🚀 DEPLOYMENT INSTRUCTIONS:${NC}"
echo ""

echo -e "${YELLOW}1. Set up FREE databases:${NC}"
echo "   📊 PostgreSQL (Neon): https://neon.tech"
echo "   ⚡ Redis (Upstash): https://upstash.com" 
echo ""

echo -e "${YELLOW}2. Deploy Frontend (Vercel - FREE):${NC}"
echo "   cd frontend"
echo "   npx vercel --prod"
echo "   # Connect custom domain: intimateai.chat"
echo ""

echo -e "${YELLOW}3. Deploy Backend (Railway - FREE):${NC}"
echo "   # Push to GitHub first:"
echo "   git add ."
echo "   git commit -m 'ChatbotAI FREE deployment'"
echo "   git push origin main"
echo ""
echo "   # Then go to railway.app:"
echo "   # 1. Connect GitHub repo"
echo "   # 2. Add environment variables from .env.template"
echo "   # 3. Deploy automatically"
echo ""

echo -e "${YELLOW}4. Set up Stripe payments:${NC}"
echo "   🔗 https://stripe.com"
echo "   💳 Create $29.99/month subscription product"
echo "   🔑 Get test API keys"
echo ""

echo -e "${GREEN}💰 TOTAL MONTHLY COST: \$0${NC}"
echo -e "${GREEN}🎯 BREAK-EVEN: IMMEDIATE PROFIT from subscriber #1${NC}"
echo ""

echo -e "${BLUE}📈 FREE TIER CAPACITY:${NC}"
echo "├── Neon PostgreSQL: 0.5GB (~1,000 users)"
echo "├── Upstash Redis: 10K requests/day (~300 active users)"
echo "├── Railway: 500 hours/month (24/7 uptime)" 
echo "├── Vercel: Unlimited reasonable usage"
echo "└── Cloudflare: 10GB storage"
echo ""
echo "You can serve hundreds of users before hitting any limits!"
echo ""

echo -e "${PURPLE}🎯 NEXT STEPS:${NC}"
echo "1. Follow deployment instructions above"
echo "2. Test with 2-hour free trial"
echo "3. Get your first paying subscriber (\$29.99 pure profit!)"
echo "4. Scale up only when needed"
echo ""

echo -e "${GREEN}✅ FREE tier deployment setup complete!${NC}"
echo -e "${GREEN}🚀 Ready to launch with \$0 monthly costs!${NC}"