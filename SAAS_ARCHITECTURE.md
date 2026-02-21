# 🏗️ PutalindaBot SaaS - Technical Architecture

## 🎯 System Overview

**Goal:** Transform existing intimate AI bot into subscription SaaS with 24h trials and Telegram delivery

**Core Components:**
1. **Subscription-Gated Telegram Bot** (primary interface)
2. **User Management & Payment System** (Stripe integration)
3. **Landing Page & Marketing Site** (conversion funnel)
4. **Admin Dashboard** (business monitoring)

## 🤖 Enhanced Telegram Bot Architecture

### **Bot Gateway with Subscription Control**
```python
# Enhanced bot with subscription checking
class SaaSTelegramBot(PutalindaBotStoryTeller):
    def __init__(self):
        super().__init__()  # Inherit existing personality system
        self.user_service = UserService()
        self.payment_service = PaymentService()
        self.trial_manager = TrialManager()
    
    def handle_message(self, update, context):
        user_id = update.effective_user.id
        
        # Check subscription status
        subscription_status = self.user_service.get_subscription_status(user_id)
        
        if subscription_status == "expired":
            return self.handle_subscription_required(user_id)
        elif subscription_status == "trial" and self.trial_manager.is_trial_expired(user_id):
            return self.handle_trial_expired(user_id)
        
        # Continue with existing bot logic
        return super().generate_and_send_response(
            update.message.text, update.effective_chat.id, user_id
        )
```

### **New Bot Commands for SaaS**
```python
SAAS_COMMANDS = {
    '/start': 'Welcome + trial signup',
    '/trial': 'Start 24-hour free trial',
    '/subscribe': 'Generate payment link',
    '/status': 'Show subscription & trial info',
    '/personalities': 'List available personalities by tier',
    '/upgrade': 'Upgrade subscription tier',
    '/support': 'Customer support bot',
    '/cancel': 'Cancel subscription (with retention flow)'
}
```

## 💳 Payment & Subscription System

### **Stripe Integration**
```python
class PaymentService:
    def __init__(self):
        stripe.api_key = os.getenv('STRIPE_SECRET_KEY')
        self.webhook_secret = os.getenv('STRIPE_WEBHOOK_SECRET')
    
    def create_trial_customer(self, telegram_id, email):
        """Create customer with 24h trial"""
        customer = stripe.Customer.create(
            email=email,
            metadata={'telegram_id': str(telegram_id)}
        )
        
        # Create subscription with 24h trial
        subscription = stripe.Subscription.create(
            customer=customer.id,
            items=[{'price': 'price_basic_monthly'}],
            trial_period_days=1,  # 24 hours
            metadata={'telegram_id': str(telegram_id)}
        )
        
        return customer, subscription
    
    def create_payment_link(self, telegram_id, plan_type):
        """Generate Stripe payment link for user"""
        price_id = {
            'basic': 'price_basic_monthly',     # $29.99
            'premium': 'price_premium_monthly', # $49.99
            'couples': 'price_couples_monthly'  # $69.99
        }[plan_type]
        
        payment_link = stripe.PaymentLink.create(
            line_items=[{'price': price_id, 'quantity': 1}],
            metadata={'telegram_id': str(telegram_id)},
            after_completion={'type': 'redirect', 'redirect': {'url': 'https://intimateai.chat/success'}}
        )
        
        return payment_link.url
```

### **Subscription Tiers**
```python
SUBSCRIPTION_TIERS = {
    'trial': {
        'duration_hours': 24,
        'personalities': ['sophia'],
        'message_limit': None,  # Unlimited during trial
        'features': ['basic_conversations']
    },
    'basic': {
        'price': 2999,  # $29.99
        'personalities': ['sophia'],
        'message_limit': None,
        'features': ['unlimited_messages', 'basic_support']
    },
    'premium': {
        'price': 4999,  # $49.99
        'personalities': ['sophia', 'emma', 'madison', 'isabella'],
        'message_limit': None,
        'features': ['all_personalities', 'priority_support', 'custom_scenarios']
    },
    'couples': {
        'price': 6999,  # $69.99
        'personalities': ['all'],
        'features': ['dual_access', 'couples_scenarios', 'relationship_insights']
    }
}
```

## 🗄️ Database Schema

### **PostgreSQL Tables**
```sql
-- Users and authentication
CREATE TABLE users (
    telegram_id BIGINT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    first_name VARCHAR(255),
    username VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    trial_used BOOLEAN DEFAULT FALSE,
    referral_code VARCHAR(10) UNIQUE,
    referred_by BIGINT REFERENCES users(telegram_id),
    last_active TIMESTAMP
);

-- Subscription management
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(telegram_id),
    stripe_customer_id VARCHAR(255) UNIQUE,
    stripe_subscription_id VARCHAR(255) UNIQUE,
    plan_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL, -- active, trialing, canceled, past_due
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    trial_start TIMESTAMP,
    trial_end TIMESTAMP,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Usage tracking for analytics
CREATE TABLE usage_sessions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(telegram_id),
    personality_used VARCHAR(50),
    message_count INTEGER,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    total_messages_today INTEGER -- Cached for rate limiting
);

-- Personality preferences per user
CREATE TABLE user_personalities (
    user_id BIGINT REFERENCES users(telegram_id),
    personality_name VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,
    customization_settings JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, personality_name)
);

-- Payment events and webhooks
CREATE TABLE payment_events (
    id SERIAL PRIMARY KEY,
    stripe_event_id VARCHAR(255) UNIQUE,
    event_type VARCHAR(255),
    user_id BIGINT REFERENCES users(telegram_id),
    amount INTEGER, -- In cents
    currency VARCHAR(3) DEFAULT 'usd',
    status VARCHAR(50),
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 🌐 Landing Page & Marketing Site

### **Site Structure**
```
intimateai.chat/
├── / (landing page)
├── /pricing (subscription tiers)
├── /personalities (showcase different AI personalities)
├── /privacy (privacy policy)
├── /terms (terms of service)
├── /support (help center)
├── /success (post-payment success)
└── /admin (internal dashboard)
```

### **Landing Page Components**
```jsx
// Modern Next.js landing page
export default function LandingPage() {
  return (
    <>
      <HeroSection 
        headline="Your Personal Intimate AI Companion"
        subheadline="Experience personalized conversations with AI personalities designed for adult relationships"
        ctaText="Start 24-Hour Free Trial"
        onCTAClick={() => window.open('https://t.me/intimateaibot?start=trial')}
      />
      
      <PersonalitiesSection personalities={availablePersonalities} />
      
      <PricingSection 
        plans={subscriptionPlans}
        highlightTrial={true}
      />
      
      <TestimonialsSection reviews={anonymizedReviews} />
      
      <FAQSection questions={commonQuestions} />
      
      <Footer />
    </>
  )
}
```

## 🚀 Trial-to-Paid Conversion Flow

### **User Journey**
```
1. User clicks "Start Trial" on landing page
   ↓
2. Redirected to Telegram bot with deep link
   ↓
3. Bot sends welcome + email collection
   ↓
4. 24-hour trial begins with full access
   ↓
5. Trial expiration notifications (12h, 2h before)
   ↓
6. Trial expires → Payment required message
   ↓
7. User clicks payment link → Stripe checkout
   ↓
8. Webhook activates subscription → Full access restored
```

### **Trial Management**
```python
class TrialManager:
    def start_trial(self, telegram_id, email):
        """Start 24-hour trial for new user"""
        trial_end = datetime.now() + timedelta(hours=24)
        
        # Create user record
        user = self.user_service.create_user(
            telegram_id=telegram_id,
            email=email,
            trial_used=True
        )
        
        # Schedule trial expiration job
        self.schedule_trial_expiration(telegram_id, trial_end)
        
        return trial_end
    
    def check_trial_status(self, telegram_id):
        """Check if user's trial is still active"""
        subscription = self.user_service.get_active_subscription(telegram_id)
        
        if subscription and subscription.status == 'trialing':
            return subscription.trial_end > datetime.now()
        
        return False
```

## 📊 Admin Dashboard

### **Key Metrics Dashboard**
```python
# Analytics for business monitoring
DASHBOARD_METRICS = {
    'revenue': {
        'mrr': 'Monthly Recurring Revenue',
        'arr': 'Annual Recurring Revenue', 
        'churn_rate': 'Monthly churn percentage',
        'ltv': 'Customer Lifetime Value'
    },
    'users': {
        'trial_signups': 'Daily trial signups',
        'trial_conversions': 'Trial to paid conversion %',
        'active_subscribers': 'Currently paying users',
        'usage_per_user': 'Average messages per user'
    },
    'technical': {
        'bot_uptime': 'Telegram bot availability',
        'response_time': 'Average bot response time',
        'error_rate': 'Failed message percentage'
    }
}
```

## 🔧 Implementation Roadmap

### **Week 1: Core Infrastructure**
- [ ] Set up PostgreSQL database with user/subscription tables
- [ ] Implement basic Stripe integration (customer creation, webhooks)
- [ ] Extend existing bot with subscription checking
- [ ] Create trial signup flow in Telegram

### **Week 2: Payment Flow**
- [ ] Build payment link generation
- [ ] Implement Stripe webhook handling
- [ ] Create subscription activation/deactivation
- [ ] Add usage tracking and analytics

### **Week 3: User Experience**
- [ ] Build trial expiration notification system
- [ ] Create customer support bot commands
- [ ] Implement personality tier restrictions
- [ ] Add subscription management commands

### **Week 4: Launch Preparation**
- [ ] Deploy landing page with pricing
- [ ] Set up monitoring and alerts
- [ ] Create admin dashboard
- [ ] Beta test with 10-20 users

### **Post-Launch: Optimization**
- [ ] A/B testing framework for conversion optimization
- [ ] Advanced analytics and cohort analysis
- [ ] Referral program implementation
- [ ] Additional personality development

---

## 💰 Revenue Projections

### **Conservative Growth Model**
```
Month 1: 50 trials → 12 paying ($358 MRR)
Month 3: 200 trials → 60 paying ($2,394 MRR)
Month 6: 500 trials → 150 paying ($5,985 MRR)
Month 12: 2000 trials → 600 paying ($23,940 MRR)

Year 1 ARR: ~$287,280
Year 2 ARR: ~$1,200,000+ (with growth optimization)
```

### **Key Success Factors**
- **25% trial conversion rate** (industry standard for adult content)
- **<10% monthly churn** (achieved through quality personalities)
- **$39.90 average revenue per user** (weighted across tiers)
- **Viral coefficient of 0.15** (referral program)

This technical architecture leverages the existing personality system while adding the subscription business layer needed for a profitable SaaS service! 🚀💰