const Features = () => {
  const features = [
    {
      icon: '📱',
      title: 'Week-by-Week Tracking',
      description: 'Track your pregnancy progress with visual indicators and trimester identification. See your baby\'s development and important milestones as they happen.'
    },
    {
      icon: '🤖',
      title: 'AI Assistant',
      description: 'Get context-aware responses based on your current pregnancy week and profile. Ask questions and receive personalized guidance tailored to your journey.'
    },
    {
      icon: '💊',
      title: 'Health Tracking',
      description: 'Log symptoms, track weight, and manage appointments all in one place. Stay organized and informed about your health throughout pregnancy.'
    }
  ]

  return (
    <section className="bg-white py-24 px-5">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-4xl md:text-5xl font-bold text-center text-text-dark mb-5">
          Everything You Need
        </h2>
        <p className="text-xl text-text-light text-center mb-16 max-w-2xl mx-auto">
          A complete pregnancy companion that grows with you through every stage of your journey
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10 mt-16">
          {features.map((feature, index) => (
            <div
              key={index}
              className="bg-white rounded-3xl p-10 shadow-lg transition-all duration-300 border-2 border-transparent hover:-translate-y-2 hover:shadow-xl hover:border-accent/20 relative overflow-hidden group"
            >
              <div 
                className="absolute top-0 left-0 w-full h-1 transform scale-x-0 transition-transform duration-300 group-hover:scale-x-100"
                style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}
              ></div>
              
              <span className="text-5xl mb-5 block">{feature.icon}</span>
              
              <h3 className="text-2xl font-semibold text-text-dark mb-4">
                {feature.title}
              </h3>
              
              <p className="text-base text-text-light leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Features

