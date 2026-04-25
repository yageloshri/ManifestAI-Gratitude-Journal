import Foundation

// The model for daily messages
struct DailyMessage {
    let title: String
    let body: String // Insight
    let affirmation: String
}

struct NumerologyService {
    static let shared = NumerologyService()
    
    // The complete database with 10 messages per number
    private let numerologyData: [Int: [DailyMessage]] = [
        
        // MARK: - Number 1: New Beginnings & Action
        1: [
            DailyMessage(title: "Seed of Potential", body: "Today is a energetic reset. The universe is asking you to plant a seed for the future. What you start today will grow.", affirmation: "I am planting the seeds of my future success."),
            DailyMessage(title: "Take the Lead", body: "Don't wait for permission. The energy today supports bold action and leadership. Be the first to move.", affirmation: "I trust my instincts and lead with confidence."),
            DailyMessage(title: "Fresh Start", body: "The past is behind you. Today brings a surge of vitality perfect for launching new projects or habits.", affirmation: "I embrace the new and release the old."),
            DailyMessage(title: "Ignite Your Spark", body: "You have extra creative fuel today. Use this momentum to push past procrastination.", affirmation: "I am a powerful creator in motion."),
            DailyMessage(title: "Be Bold", body: "Courage is your keyword today. Step out of your comfort zone—the universe rewards bravery right now.", affirmation: "I act with courage and clarity."),
            DailyMessage(title: "Self-Reliance", body: "Trust yourself. Today's vibration encourages independence and standing on your own two feet.", affirmation: "I am sufficient and strong."),
            DailyMessage(title: "Innovation Mode", body: "Look at problems with fresh eyes. A new solution is available if you change your perspective.", affirmation: "I see new possibilities everywhere."),
            DailyMessage(title: "Day of Firsts", body: "Do something you've never done before. The energy of '1' loves novelty and exploration.", affirmation: "I open my heart to new experiences."),
            DailyMessage(title: "Focus Forward", body: "Don't look back. Your power is in the present moment, creating what comes next.", affirmation: "My eyes are fixed on my goals."),
            DailyMessage(title: "The Pioneer", body: "You are clearing a path. It might feel lonely, but you are leading the way for abundance.", affirmation: "I am the architect of my destiny.")
        ],

        // MARK: - Number 2: Balance & Partnership
        2: [
            DailyMessage(title: "Power of Patience", body: "Do not rush. Today is about the space between notes. Let the universe work its magic in the background.", affirmation: "I trust the divine timing of my life."),
            DailyMessage(title: "Connect & Collaborate", body: "Two heads are better than one today. Seek a partner or a friend to share your vision with.", affirmation: "I attract supportive and loving relationships."),
            DailyMessage(title: "Gentle Flow", body: "Pushing hard will create resistance. Be like water—flow around obstacles rather than through them.", affirmation: "I flow with peace and ease."),
            DailyMessage(title: "Listen Deeply", body: "Your intuition is heightened. Pay attention to whispers, dreams, and subtle signs.", affirmation: "I listen to the wisdom of my inner voice."),
            DailyMessage(title: "Diplomacy Wins", body: "If conflict arises, be the peacemaker. Softness is your strength today, not weakness.", affirmation: "I bring harmony to every situation."),
            DailyMessage(title: "Wait for It", body: "The seed is underground. Just because you don't see results yet, doesn't mean they aren't growing.", affirmation: "I am patient with my process."),
            DailyMessage(title: "Emotional Balance", body: "Check in with your feelings. Today favors emotional intelligence over cold logic.", affirmation: "I honor my feelings and find balance."),
            DailyMessage(title: "Divine Details", body: "Notice the small things. A subtle conversation today could lead to a big breakthrough later.", affirmation: "I am attentive to the signs of the universe."),
            DailyMessage(title: "Support System", body: "Ask for help if you need it. You don't have to carry the world on your shoulders today.", affirmation: "I allow myself to be supported."),
            DailyMessage(title: "Peaceful Mind", body: "Quiet the noise. Your best answers will come in moments of silence and calm.", affirmation: "My mind is a sanctuary of peace.")
        ],

        // MARK: - Number 3: Creativity & Expression
        3: [
            DailyMessage(title: "Express Yourself", body: "Your voice is your wand today. Speak up, write, or create. The world needs your unique frequency.", affirmation: "My voice is powerful and clear."),
            DailyMessage(title: "Radiate Joy", body: "Laughter is the highest vibration. Find reasons to smile and spread optimism to others.", affirmation: "I am a beacon of joy and light."),
            DailyMessage(title: "Social Butterfly", body: "Connect with others. Today favors networking, socializing, and sharing ideas openly.", affirmation: "I attract amazing people into my life."),
            DailyMessage(title: "Creative Spark", body: "Make art, cook, or design. Your creative channel is wide open—use it.", affirmation: "Creativity flows through me effortlessly."),
            DailyMessage(title: "Speak Your Truth", body: "Don't hold back. Authentic communication will unlock doors for you today.", affirmation: "I speak my truth with love."),
            DailyMessage(title: "Optimism Rules", body: "Focus on the bright side. Your attitude today determines your altitude.", affirmation: "I choose to see the good in everything."),
            DailyMessage(title: "Be Visible", body: "Don't hide your light. Step into the spotlight and let people see who you really are.", affirmation: "It is safe for me to shine."),
            DailyMessage(title: "Playful Energy", body: "Don't take life too seriously today. Approach tasks with a sense of play and curiosity.", affirmation: "I embrace the playful energy of life."),
            DailyMessage(title: "Magnetic Charm", body: "You are naturally attractive today. Use this charisma to attract what you desire.", affirmation: "I am magnetic to my desires."),
            DailyMessage(title: "Communication Flow", body: "Send that email or make that call. Words flow easily for you right now.", affirmation: "I communicate with clarity and confidence.")
        ],

        // MARK: - Number 4: Foundation & Work
        4: [
            DailyMessage(title: "Build Your Empire", body: "Brick by brick. Today is not about flash, it's about solid foundations and hard work.", affirmation: "I am building a stable future."),
            DailyMessage(title: "Get Organized", body: "Chaos blocks manifestation. Clean your desk, sort your list, and clear your space.", affirmation: "My outer order reflects my inner calm."),
            DailyMessage(title: "Stay Grounded", body: "Focus on facts and details. This is a day for logic, planning, and practical steps.", affirmation: "I am grounded, focused, and secure."),
            DailyMessage(title: "Discipline Pays Off", body: "Do the work even if you don't feel like it. The effort you put in today yields long-term rewards.", affirmation: "I love the discipline that leads to freedom."),
            DailyMessage(title: "Secure Your Base", body: "Check your finances, health, or home. Strengthen the pillars of your life.", affirmation: "I am safe and financially secure."),
            DailyMessage(title: "Step by Step", body: "Don't look at the whole mountain. Just take the next logical step. Progress is happening.", affirmation: "I trust the process of slow growth."),
            DailyMessage(title: "Practical Magic", body: "Manifestation requires action. Put your plans into physical motion today.", affirmation: "I turn my dreams into reality through work."),
            DailyMessage(title: "Commitment", body: "Stick to your promises. Reliability raises your vibration today.", affirmation: "I am reliable and committed to my path."),
            DailyMessage(title: "Master the Details", body: "Don't skim the surface. Go deep into the details to find the gold.", affirmation: "I am thorough and precise."),
            DailyMessage(title: "Solid Roots", body: "Like a tree, you must grow roots before you grow branches. Focus on your stability.", affirmation: "My roots are deep and my foundation is strong.")
        ],

        // MARK: - Number 5: Change & Freedom
        5: [
            DailyMessage(title: "Expect the Unexpected", body: "Routine is the enemy today. Be open to surprises and shifts in your schedule.", affirmation: "I flow with the changes of life."),
            DailyMessage(title: "Adventure Awaits", body: "Say yes to something new. The energy favors exploration and leaving your comfort zone.", affirmation: "I am an adventurous spirit."),
            DailyMessage(title: "Embrace Freedom", body: "If you feel stuck, shake things up. You are meant to feel free and unconfined today.", affirmation: "I am free to create the life I want."),
            DailyMessage(title: "Dynamic Movement", body: "Move your body. Stagnant energy needs to be released through activity or travel.", affirmation: "I am full of energy and vitality."),
            DailyMessage(title: "Pivot Point", body: "A change of direction is possible. Be flexible and ready to adapt.", affirmation: "I adapt easily to new situations."),
            DailyMessage(title: "Take a Risk", body: "Calculated risks are favored. Don't play it safe—play it big.", affirmation: "I am brave enough to take chances."),
            DailyMessage(title: "Social Expansion", body: "You might meet someone unusual today. Be open to diverse perspectives.", affirmation: "I learn from everyone I meet."),
            DailyMessage(title: "Break the Pattern", body: "Do one thing differently today. Drive a new route, eat a new food. Break the loop.", affirmation: "I break free from old limitations."),
            DailyMessage(title: "Communication Spike", body: "News might come in fast. Stay alert and process information quickly.", affirmation: "I handle information with clarity."),
            DailyMessage(title: "Wild Card", body: "Anything can happen today. Keep your vibration high and ride the wave.", affirmation: "I trust the universe's surprises.")
        ],

        // MARK: - Number 6: Love & Responsibility
        6: [
            DailyMessage(title: "Heart Centered", body: "Make decisions with your heart today. Logic takes a backseat to love and compassion.", affirmation: "I lead with my heart."),
            DailyMessage(title: "Nurture Yourself", body: "You can't pour from an empty cup. Take care of your needs before serving others.", affirmation: "I love and care for myself deeply."),
            DailyMessage(title: "Domestic Harmony", body: "Focus on your home. Beautify your space or cook a meal. Your environment affects your vibe.", affirmation: "My home is a sanctuary of love."),
            DailyMessage(title: "Be of Service", body: "Helping someone else will boost your own abundance frequency today.", affirmation: "I give and receive love freely."),
            DailyMessage(title: "Healing Energy", body: "This is a great day for emotional or physical healing. Be gentle with yourself.", affirmation: "I am healing every day."),
            DailyMessage(title: "Family First", body: "Connect with family or close friends. Relationships are the priority right now.", affirmation: "I cherish my loved ones."),
            DailyMessage(title: "Create Beauty", body: "Surround yourself with beauty. Buy flowers, listen to music, or dress up.", affirmation: "I see beauty in everything."),
            DailyMessage(title: "Resolve Conflict", body: "The energy supports forgiveness. Let go of a grudge to lighten your load.", affirmation: "I forgive and set myself free."),
            DailyMessage(title: "Balance Duty", body: "Fulfill your responsibilities with grace. There is dignity in caring for others.", affirmation: "I handle my responsibilities with ease."),
            DailyMessage(title: "Love Magnet", body: "You are radiating loving energy. It's a powerful day for romance and connection.", affirmation: "I am open to receiving love.")
        ],

        // MARK: - Number 7: Reflection & Wisdom
        7: [
            DailyMessage(title: "Go Within", body: "Step back from the noise. Your answers aren't on social media, they are inside you.", affirmation: "I find peace in silence."),
            DailyMessage(title: "Trust Intuition", body: "Your gut feeling is accurate today. Analyze less, feel more.", affirmation: "I trust my inner guidance."),
            DailyMessage(title: "Seek Wisdom", body: "Read, study, or research. Your mind is sharp and ready to uncover deep truths.", affirmation: "I seek truth and understanding."),
            DailyMessage(title: "Spiritual Download", body: "Pay attention to sudden insights. You are connected to a higher channel today.", affirmation: "I am connected to the universe."),
            DailyMessage(title: "Rest & Recharge", body: "Don't push. Today is for mental and spiritual recovery, not physical hustle.", affirmation: "Rest is productive for me."),
            DailyMessage(title: "Analyze Patterns", body: "Look at your life objectively. What patterns are repeating? You have the clarity to see them.", affirmation: "I see the truth clearly."),
            DailyMessage(title: "Nature Connection", body: "Spend time outdoors. Nature will help ground your high-frequency thoughts.", affirmation: "Nature restores my soul."),
            DailyMessage(title: "Private Mode", body: "It's okay to be alone. Solitude is where your genius is born today.", affirmation: "I enjoy my own company."),
            DailyMessage(title: "Question Everything", body: "Don't accept things at face value. Dig deeper to find the real meaning.", affirmation: "I look beyond the surface."),
            DailyMessage(title: "Mystical Alignment", body: "The veil is thin. Meditate or visualize your desires with focus.", affirmation: "My mind is a powerful tool for manifestation.")
        ],

        // MARK: - Number 8: Power & Abundance
        8: [
            DailyMessage(title: "Boss Energy", body: "Step into your authority. Today is for big goals, business decisions, and financial moves.", affirmation: "I am powerful and capable."),
            DailyMessage(title: "Manifest Money", body: "The frequency of wealth is high today. Focus on abundance, not lack.", affirmation: "Money flows to me easily."),
            DailyMessage(title: "Take Charge", body: "Don't wait for things to happen—make them happen. You are the CEO of your life.", affirmation: "I am in control of my destiny."),
            DailyMessage(title: "Karma in Action", body: "What you put out comes back multiplied today. Put out excellence.", affirmation: "I reap what I sow."),
            DailyMessage(title: "Ambitious Goals", body: "Think bigger. The energy supports expansion and reaching for the next level.", affirmation: "I achieve my goals with ease."),
            DailyMessage(title: "Practical Power", body: "Combine vision with execution. It's not enough to dream; you must do.", affirmation: "I take powerful action today."),
            DailyMessage(title: "Financial Focus", body: "Review your investments or pricing. It's a good day to secure your wealth.", affirmation: "I am a wise manager of my resources."),
            DailyMessage(title: "Overcome Obstacles", body: "You have the strength to crush any barrier today. Nothing can stop you.", affirmation: "I am stronger than any challenge."),
            DailyMessage(title: "Success Mindset", body: "Dress for success and act the part. Confidence attracts opportunity.", affirmation: "I radiate success and confidence."),
            DailyMessage(title: "Harvest Time", body: "You may receive rewards for past work today. Accept them with gratitude.", affirmation: "I receive abundance with gratitude.")
        ],

        // MARK: - Number 9: Completion & Release
        9: [
            DailyMessage(title: "Let It Go", body: "Release what is heavy. A cycle is ending to make room for a better one.", affirmation: "I release the past with love."),
            DailyMessage(title: "Declutter Life", body: "Clean your phone, your closet, or your friend list. Remove the old to invite the new.", affirmation: "I make space for new blessings."),
            DailyMessage(title: "Compassion", body: "Forgive yourself and others. Holding onto anger blocks your manifestation flow.", affirmation: "I forgive and I am free."),
            DailyMessage(title: "Global Vision", body: "Think about how you can help others. Selflessness raises your vibration today.", affirmation: "I contribute to the world with love."),
            DailyMessage(title: "Wrap It Up", body: "Finish unfinished tasks. Don't start new things yet—close the open loops.", affirmation: "I complete my tasks with satisfaction."),
            DailyMessage(title: "Trust the End", body: "Endings are just disguised beginnings. Trust that something better is coming.", affirmation: "I trust the cycles of life."),
            DailyMessage(title: "Emotional Release", body: "It's okay to cry or feel deeply. Let the emotions flow through you to clear the block.", affirmation: "I process my emotions healthily."),
            DailyMessage(title: "Wisdom Gained", body: "Look back at how far you've come. Acknowledge the lessons you've learned.", affirmation: "I am grateful for my journey."),
            DailyMessage(title: "Humanitarian Vibe", body: "Do a random act of kindness. The universe rewards generosity today.", affirmation: "I am kind and generous."),
            DailyMessage(title: "Surrender", body: "Stop fighting the current. Surrender your control to the universe and trust.", affirmation: "I surrender to the flow of the universe.")
        ]
    ]
    
    func calculatePersonalDayNumber(birthDate: Date?) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        let currentDay = calendar.component(.day, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        var sum = 0
        
        if let birthDate = birthDate {
            let birthDay = calendar.component(.day, from: birthDate)
            let birthMonth = calendar.component(.month, from: birthDate)
            
            // Personal Day = Birth Day + Birth Month + Current Day + Current Month + Current Year
            sum = birthDay + birthMonth + currentDay + currentMonth + currentYear
        } else {
            // Universal Day = Current Day + Current Month + Current Year
            sum = currentDay + currentMonth + currentYear
        }
        
        return reduceToSingleDigit(sum)
    }
    
    /// Get a random daily message for the given number
    func getDailyMessage(for number: Int) -> DailyMessage {
        guard let messages = numerologyData[number], !messages.isEmpty else {
            return DailyMessage(
                title: "Universal Energy",
                body: "Align with the cosmic flow today.",
                affirmation: "I am in harmony with the universe."
            )
        }
        
        // Get a random message for this number
        return messages.randomElement() ?? messages[0]
    }
    
    /// Get a deterministic message based on the current date (for consistency throughout the day)
    func getDailyMessageDeterministic(for number: Int) -> DailyMessage {
        guard let messages = numerologyData[number], !messages.isEmpty else {
            return DailyMessage(
                title: "Universal Energy",
                body: "Align with the cosmic flow today.",
                affirmation: "I am in harmony with the universe."
            )
        }
        
        // Use day of year as seed for consistent message throughout the day
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % messages.count
        
        return messages[index]
    }
    
    /// Legacy method for backwards compatibility
    func getInsight(for number: Int) -> (title: String, description: String) {
        let message = getDailyMessageDeterministic(for: number)
        return (message.title, message.body)
    }
    
    private func reduceToSingleDigit(_ number: Int) -> Int {
        var n = number
        while n > 9 && n != 11 && n != 22 {
            var sum = 0
            while n > 0 {
                sum += n % 10
                n /= 10
            }
            n = sum
        }
        // Further reduce master numbers for the 1-9 daily cycle
        while n > 9 {
             var sum = 0
             while n > 0 {
                 sum += n % 10
                 n /= 10
             }
             n = sum
        }
        return n
    }
}
