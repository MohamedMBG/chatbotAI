#!/bin/bash
# GitHub Issues → GSD Integration Script
# Transforms ChatbotAI GitHub issues into GSD-compatible structure

set -e

echo "🔄 ChatbotAI: GitHub Issues → GSD Integration"
echo "============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}📋 Current Issues Analysis:${NC}"

# Fetch current issues
gh issue list --repo epiphanyapps/chatbotAI --json number,title,labels

echo ""
echo -e "${PURPLE}🎯 GSD Milestone Structure:${NC}"
echo ""

echo "MILESTONE 1: MVP LAUNCH 🚀"
echo "├── Phase 1: Domain & Infrastructure Foundation"
echo "│   ├── Issue #1: Domain Purchase & Setup"  
echo "│   ├── Issue #12: Terraform Infrastructure" 
echo "│   └── Issue #13: FREE Tier Deployment"
echo "├── Phase 2: Core Application & Payments"
echo "│   ├── Issue #2: Stripe Payment Integration"
echo "│   ├── Issue #3: Database Schema & Backend API"
echo "│   └── Issue #4: Telegram Bot Integration"  
echo "├── Phase 3: Web Frontend & Personalities"
echo "│   ├── Issue #5: Landing Page Development"
echo "│   └── Issue #7: Multi-Personality System"
echo "└── Phase 4: Legal Compliance & Launch"
echo "    ├── Issue #6: Legal Compliance Framework"
echo "    └── Issue #11: 2-Hour Free Trial System"
echo ""

echo "MILESTONE 2: GROWTH & OPTIMIZATION 📈"
echo "├── Phase 5: Marketing & Customer Acquisition" 
echo "│   ├── Issue #8: Customer Acquisition Strategy"
echo "│   └── Issue #10: Web-First Architecture"
echo "└── Phase 6: Advanced Features & Scaling"
echo "    ├── Issue #9: Project Roadmap Implementation"
echo "    └── Issue #14: Launch Readiness Tasks"
echo ""

echo -e "${YELLOW}🏗️ Creating GSD-Compatible GitHub Structure:${NC}"

# Create milestone labels for GitHub issues
echo "Creating GitHub milestones and labels..."

# Create Milestone 1: MVP Launch
gh api repos/epiphanyapps/chatbotAI/milestones \
  --method POST \
  --field title="MVP Launch" \
  --field description="Core functionality for adult AI SaaS launch with FREE tier deployment" \
  --field state="open" \
  2>/dev/null || echo "Milestone 'MVP Launch' already exists"

# Create Milestone 2: Growth & Optimization  
gh api repos/epiphanyapps/chatbotAI/milestones \
  --method POST \
  --field title="Growth & Optimization" \
  --field description="Marketing, scaling, and advanced features for growth to 50+ subscribers" \
  --field state="open" \
  2>/dev/null || echo "Milestone 'Growth & Optimization' already exists"

# Create GSD phase labels
declare -a labels=(
  "gsd:phase-1|Domain & Infrastructure|0366d6"
  "gsd:phase-2|Core App & Payments|1d76db" 
  "gsd:phase-3|Frontend & Personalities|28a745"
  "gsd:phase-4|Legal & Launch|d73a4a"
  "gsd:phase-5|Marketing & Acquisition|6f42c1"
  "gsd:phase-6|Advanced Features|f9ca24"
  "gsd:milestone-1|MVP Launch|e99695"
  "gsd:milestone-2|Growth & Optimization|c2e0c6"
  "gsd:critical|Critical Path|b60205"
  "gsd:ready|Ready for GSD|0e8a16"
)

for label_spec in "${labels[@]}"; do
  IFS='|' read -r name description color <<< "$label_spec"
  gh label create "$name" --description "$description" --color "$color" --repo epiphanyapps/chatbotAI 2>/dev/null || \
  echo "Label '$name' already exists"
done

echo ""
echo -e "${GREEN}✅ GitHub structure created!${NC}"
echo ""

echo -e "${BLUE}🔄 Assigning Issues to GSD Structure:${NC}"

# Get milestone IDs
mvp_milestone_id=$(gh api repos/epiphanyapps/chatbotAI/milestones | jq -r '.[] | select(.title=="MVP Launch") | .number')
growth_milestone_id=$(gh api repos/epiphanyapps/chatbotAI/milestones | jq -r '.[] | select(.title=="Growth & Optimization") | .number')

# Assign issues to milestones and phases (using portable approach)
assign_issue() {
  local issue_num=$1
  local milestone=$2
  shift 2
  local labels=("$@")
  
  # Assign milestone
  gh issue edit "$issue_num" --milestone "$milestone" --repo epiphanyapps/chatbotAI
  
  # Add labels
  for label in "${labels[@]}"; do
    gh issue edit "$issue_num" --add-label "$label" --repo epiphanyapps/chatbotAI
  done
  
  echo "Issue #$issue_num: Updated with milestone $milestone and labels: ${labels[*]}"
}

# MVP Launch assignments
assign_issue 1 "$mvp_milestone_id" "gsd:phase-1" "gsd:critical"     # Domain Purchase
assign_issue 2 "$mvp_milestone_id" "gsd:phase-2" "gsd:critical"     # Stripe Integration
assign_issue 3 "$mvp_milestone_id" "gsd:phase-2"                    # Database Schema
assign_issue 4 "$mvp_milestone_id" "gsd:phase-2"                    # Telegram Bot
assign_issue 5 "$mvp_milestone_id" "gsd:phase-3" "gsd:critical"     # Landing Page
assign_issue 6 "$mvp_milestone_id" "gsd:phase-4" "gsd:critical"     # Legal Compliance
assign_issue 7 "$mvp_milestone_id" "gsd:phase-3"                    # Multi-Personality
assign_issue 11 "$mvp_milestone_id" "gsd:phase-4" "gsd:critical"    # Trial System
assign_issue 12 "$mvp_milestone_id" "gsd:phase-1" "gsd:ready"       # Terraform (DONE)
assign_issue 13 "$mvp_milestone_id" "gsd:phase-1" "gsd:ready"       # FREE Tier (DONE)
assign_issue 14 "$mvp_milestone_id" "gsd:phase-4" "gsd:critical"    # Launch Readiness

# Growth & Optimization assignments
assign_issue 8 "$growth_milestone_id" "gsd:phase-5"                 # Marketing Strategy
assign_issue 9 "$growth_milestone_id" "gsd:phase-6"                 # Project Roadmap
assign_issue 10 "$growth_milestone_id" "gsd:phase-5"                # Web-First Architecture

echo ""
echo -e "${PURPLE}📊 GSD Project Board Summary:${NC}"
echo ""

echo "CRITICAL PATH ISSUES (Block Launch):"
echo "├── Issue #1: Domain Purchase (Phase 1) - 5 minutes, \$12/year"
echo "├── Issue #2: Stripe Adult Merchant (Phase 2) - Submit application"  
echo "├── Issue #5: Landing Page (Phase 3) - Professional design"
echo "├── Issue #6: Legal Compliance (Phase 4) - ToS, Privacy Policy"
echo "├── Issue #11: Trial System (Phase 4) - 2-hour trials"
echo "└── Issue #14: Launch Readiness (Phase 4) - Final coordination"
echo ""

echo "COMPLETED ISSUES:"
echo "├── Issue #12: ✅ Terraform Infrastructure (Production-ready)"
echo "└── Issue #13: ✅ FREE Tier Deployment (\$0/month architecture)"
echo ""

echo -e "${GREEN}🎯 Next Steps with GSD:${NC}"
echo ""
echo "1. Start Claude Code in this directory"
echo "2. Run: /gsd:help (verify GSD installation)"  
echo "3. Run: /gsd:set-profile quality (use Opus for highest quality)"
echo "4. Run: /gsd:new-project (initialize with adult AI SaaS context)"
echo "5. Run: /gsd:discuss-phase 1 (start with Domain & Infrastructure)"
echo ""

echo -e "${BLUE}📋 GSD Workflow Commands:${NC}"
echo ""
echo "# Project Setup"
echo "/gsd:new-project           # Initialize ChatbotAI with context"
echo "/gsd:set-profile quality   # Use Opus for planning & execution"
echo ""
echo "# Phase Development"  
echo "/gsd:discuss-phase 1       # Capture implementation preferences"
echo "/gsd:plan-phase 1          # Research + create atomic plans"
echo "/gsd:execute-phase 1       # Parallel execution with fresh context"
echo "/gsd:verify-work 1         # Manual testing & verification"
echo ""
echo "# Progress Tracking"
echo "/gsd:progress              # Current status & next steps"
echo "/gsd:add-todo 'idea'       # Capture ideas for later"
echo "/gsd:quick                 # Execute small tasks quickly"
echo ""

echo -e "${YELLOW}💡 GSD Benefits for ChatbotAI:${NC}"
echo ""
echo "✅ Context Engineering: Fresh 200k context per task"
echo "✅ Opus Quality: Highest-quality AI for critical development"  
echo "✅ Parallel Execution: Multiple tasks run simultaneously"
echo "✅ Atomic Commits: Perfect git history, easy rollbacks"
echo "✅ Business Focus: Each phase delivers customer value"
echo "✅ Verification: Built-in testing prevents bugs"
echo ""

echo -e "${GREEN}🚀 Ready for GSD-powered development!${NC}"
echo ""
echo "Your GitHub issues are now organized into systematic GSD phases."
echo "Launch Claude Code and start with /gsd:new-project to begin!"
echo ""