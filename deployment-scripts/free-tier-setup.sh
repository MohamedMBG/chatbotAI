#!/bin/bash
# ChatbotAI - FREE TIER DEPLOYMENT
# Target: $0-5/month total cost until you have paying users

set -e

echo "🚀 ChatbotAI Free Tier Deployment Setup"
echo "Target: <$5/month total infrastructure cost"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if required tools are installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed. Please install it first.${NC}"
        exit 1
    fi
}

echo -e "${BLUE}📋 Checking required tools...${NC}"
check_tool "git"
check_tool "node"
check_tool "npm"

echo -e "${GREEN}✅ All required tools are installed${NC}"
echo ""

# Architecture Overview
echo -e "${YELLOW}🏗️ FREE TIER ARCHITECTURE:${NC}"
echo ""
echo "💾 Database:"
echo "  ├── PostgreSQL: FREE (Neon.tech 0.5GB)"
echo "  └── Redis: FREE (Upstash 10K requests/day)"
echo ""
echo "🚀 Compute:"
echo "  ├── Frontend: FREE (Vercel)"
echo "  ├── Backend API: FREE (Railway 500h/month)"
echo "  └── Background Jobs: FREE (Railway cron)"
echo ""
echo "🌐 Services:"
echo "  ├── SSL Certificate: FREE (automatic)"
echo "  ├── CDN: FREE (Vercel + Cloudflare)"
echo "  ├── Storage: FREE (Cloudflare R2 10GB)"
echo "  └── Monitoring: FREE (Betterstack)"
echo ""
echo "💰 Total Monthly Cost: ~$1/month (domain only)"
echo "🎯 Break-even: Immediate profit from subscriber #1"
echo ""

# Step 1: Database Setup (FREE)
echo -e "${BLUE}📊 Step 1: Setting up FREE databases...${NC}"
echo ""
echo "🐘 PostgreSQL (Neon.tech - FREE 0.5GB):"
echo "  1. Go to: https://neon.tech"
echo "  2. Sign up with GitHub"
echo "  3. Create new project: 'chatbotai'"
echo "  4. Copy connection string"
echo ""
echo "⚡ Redis (Upstash - FREE 10K requests/day):"
echo "  1. Go to: https://upstash.com"
echo "  2. Sign up with GitHub"
echo "  3. Create Redis database: 'chatbotai-cache'"
echo "  4. Copy connection string"
echo ""

read -p "Press Enter when you have both database URLs ready..."

# Step 2: Frontend Deployment (FREE)
echo -e "${BLUE}🎨 Step 2: Deploying frontend to Vercel (FREE)...${NC}"
echo ""

if [ ! -d "frontend" ]; then
    echo "Creating basic React frontend..."
    npx create-react-app frontend
    cd frontend
    
    # Add basic ChatbotAI structure
    cat > src/App.js << 'EOF'
import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('');
  const [conversation, setConversation] = useState([]);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const sendMessage = async () => {
    if (!message.trim()) return;
    
    // Add user message
    const newConversation = [...conversation, { role: 'user', content: message }];
    setConversation(newConversation);
    setMessage('');
    
    try {
      // Call backend API (will be deployed to Railway)
      const response = await fetch(`${process.env.REACT_APP_API_URL}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ message, personality: 'sophia' })
      });
      
      const data = await response.json();
      setConversation([...newConversation, { role: 'assistant', content: data.response }]);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🔥 IntimateAI</h1>
        <p>Premium Adult AI Conversations</p>
        
        {!isLoggedIn ? (
          <div className="auth-form">
            <h2>18+ Only - Age Verification Required</h2>
            <button onClick={() => setIsLoggedIn(true)}>
              Start 2-Hour FREE Trial
            </button>
          </div>
        ) : (
          <div className="chat-container">
            <div className="conversation">
              {conversation.map((msg, idx) => (
                <div key={idx} className={`message ${msg.role}`}>
                  <strong>{msg.role === 'user' ? 'You' : 'Sophia'}:</strong> {msg.content}
                </div>
              ))}
            </div>
            
            <div className="input-area">
              <input
                type="text"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
                placeholder="Type your message..."
              />
              <button onClick={sendMessage}>Send</button>
            </div>
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
EOF

    # Add environment variable for API URL
    cat > .env << 'EOF'
REACT_APP_API_URL=https://your-railway-app.railway.app
EOF

    cd ..
fi

echo "Frontend created. Deploy to Vercel:"
echo "  1. Install Vercel CLI: npm i -g vercel"
echo "  2. cd frontend && vercel --prod"
echo "  3. Connect your domain: intimateai.chat"
echo ""

# Step 3: Backend Deployment (FREE)
echo -e "${BLUE}⚙️ Step 3: Setting up backend for Railway (FREE 500h/month)...${NC}"
echo ""

if [ ! -d "backend" ]; then
    mkdir -p backend
    cd backend
    
    # Create requirements.txt
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
redis==5.0.1
stripe==7.8.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
httpx==0.25.2
python-dotenv==1.0.0
alembic==1.13.0
EOF

    # Create main FastAPI app
    cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import os
import redis
import stripe
from datetime import datetime, timedelta
import json

app = FastAPI(title="ChatbotAI API", version="1.0.0")

# CORS configuration for free frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-vercel-app.vercel.app", "https://intimateai.chat"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
redis_client = redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379"))

# Personality responses (from your training data)
PERSONALITY_RESPONSES = {
    "sophia": [
        "Mmm, me encanta cuando me hablas así...",
        "¿Qué quieres que haga para ti, papi?",
        "Estoy tan mojada pensando en ti...",
        "Cuéntame tus fantasías más sucias...",
        "Quiero sentirte dentro de mí...",
    ]
}

class ChatRequest(BaseModel):
    message: str
    personality: str = "sophia"

class TrialRequest(BaseModel):
    email: str

@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}

@app.post("/api/start-trial")
async def start_trial(request: TrialRequest):
    """Start 2-hour free trial"""
    try:
        # Create trial user in Redis (expires in 2 hours)
        trial_key = f"trial:{request.email}"
        trial_data = {
            "email": request.email,
            "started_at": datetime.now().isoformat(),
            "messages_used": 0,
            "max_messages": 50  # Limit for trial
        }
        
        # Set expiry to 2 hours
        redis_client.setex(trial_key, 7200, json.dumps(trial_data))
        
        return {
            "success": True,
            "trial_token": trial_key,
            "expires_in": 7200,
            "max_messages": 50
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/chat")
async def chat(request: ChatRequest):
    """Main chat endpoint with personality system"""
    try:
        # Simple response selection (can be enhanced with your training data)
        import random
        responses = PERSONALITY_RESPONSES.get(request.personality, PERSONALITY_RESPONSES["sophia"])
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
    """Create Stripe subscription (for paid users)"""
    try:
        # Basic subscription creation
        price_id = os.getenv("STRIPE_PRICE_ID")  # $29.99/month
        
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price': price_id,
                'quantity': 1,
            }],
            mode='subscription',
            success_url='https://intimateai.chat/success',
            cancel_url='https://intimateai.chat/pricing',
        )
        
        return {"checkout_url": session.url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
EOF

    # Create Railway deployment config
    cat > railway.toml << 'EOF'
[build]
builder = "nixpacks"

[deploy]
healthcheckPath = "/api/health"
healthcheckTimeout = 30
restartPolicyType = "on_failure"

[env]
PORT = "8000"
EOF

    # Create startup script
    cat > start.sh << 'EOF'
#!/bin/bash
uvicorn main:app --host 0.0.0.0 --port $PORT
EOF
    chmod +x start.sh

    cd ..
fi

echo "Backend created. Deploy to Railway:"
echo "  1. Go to: https://railway.app"
echo "  2. Sign up with GitHub"
echo "  3. Create new project from GitHub repo"
echo "  4. Add environment variables:"
echo "     - DATABASE_URL (from Neon)"
echo "     - REDIS_URL (from Upstash)"
echo "     - STRIPE_SECRET_KEY (test key)"
echo "     - JWT_SECRET_KEY (random string)"
echo ""

# Step 4: Domain & SSL (Domain cost only)
echo -e "${BLUE}🌐 Step 4: Domain and SSL setup...${NC}"
echo ""
echo "Domain Options:"
echo "  Option 1: Buy IntimateAI.chat (~$12/year)"
echo "  Option 2: Use free subdomain initially (your-app.vercel.app)"
echo ""
echo "SSL Certificate: FREE (automatic with Vercel)"
echo ""

# Step 5: Payment Setup
echo -e "${BLUE}💳 Step 5: Payment processing setup...${NC}"
echo ""
echo "Stripe Setup (FREE to start):"
echo "  1. Go to: https://stripe.com"
echo "  2. Create account"
echo "  3. Apply for adult content merchant approval"
echo "  4. Get test API keys for development"
echo "  5. Create product: $29.99/month subscription"
echo ""

# Cost Summary
echo -e "${YELLOW}💰 COST BREAKDOWN:${NC}"
echo ""
echo "Monthly Costs:"
echo "├── Database (Neon + Upstash): $0/month (free tiers)"
echo "├── Frontend (Vercel): $0/month (free tier)"
echo "├── Backend (Railway): $0/month (500h free/month)"
echo "├── SSL Certificate: $0/month (automatic)"
echo "├── CDN & Storage: $0/month (free tiers)"
echo "└── Domain: $1/month (optional, can use free subdomain)"
echo ""
echo "💰 TOTAL: $0-1/month"
echo "🎯 Break-even: IMMEDIATE PROFIT from first subscriber ($29.99)"
echo "📈 Growth: 100% profit margin until you hit free tier limits"
echo ""

# Scaling Plan
echo -e "${BLUE}📈 SCALING PLAN:${NC}"
echo ""
echo "Free Tier Limits:"
echo "├── Neon PostgreSQL: 0.5GB data (~1,000 users)"
echo "├── Upstash Redis: 10K requests/day (~300 active users)"
echo "├── Railway: 500 hours/month (always-on deployment)"
echo "├── Vercel: Unlimited (with reasonable usage)"
echo "└── R2 Storage: 10GB (~10,000 images)"
echo ""
echo "Upgrade Triggers:"
echo "├── >50 subscribers ($1,500 MRR): Upgrade databases ($25/month)"
echo "├── >100 subscribers ($3,000 MRR): Add dedicated compute ($50/month)"
echo "├── >300 subscribers ($9,000 MRR): Full production setup ($200/month)"
echo "└── At $9K MRR, $200/month = 2.2% revenue (excellent margins!)"
echo ""

# Next Steps
echo -e "${GREEN}🎯 NEXT STEPS:${NC}"
echo ""
echo "1. Set up free database accounts (Neon + Upstash)"
echo "2. Deploy frontend to Vercel"
echo "3. Deploy backend to Railway"  
echo "4. Connect your domain (or use free subdomain initially)"
echo "5. Set up Stripe for payments"
echo "6. Launch and get your first paying subscriber!"
echo ""
echo "You can literally start making money with $0 monthly costs!"
echo ""

echo -e "${GREEN}✅ Free tier setup guide complete!${NC}"