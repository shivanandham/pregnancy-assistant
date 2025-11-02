const AdditionalFeatures = () => {
  const features = [
    { icon: '📅', title: 'Due Date Countdown', description: 'Track your progress with a customizable due date countdown' },
    { icon: '📝', title: 'Daily Checklists', description: 'Personalized daily tasks and reminders based on your week' },
    { icon: '📊', title: 'Progress Visualization', description: 'Visual timeline showing your pregnancy journey and milestones' },
    { icon: '🏥', title: 'Appointment Management', description: 'Schedule and track your medical appointments with reminders' },
    { icon: '📈', title: 'Weight Tracking', description: 'Monitor your weight with charts and trend analysis' },
    { icon: '💡', title: 'Educational Content', description: 'Weekly tips, facts, and advice personalized to your stage' }
  ]

  return (
    <section className="bg-gray-50 py-24 px-5">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-4xl md:text-5xl font-bold text-center text-text-dark mb-5">
          More Amazing Features
        </h2>
        <p className="text-xl text-text-light text-center mb-10 max-w-2xl mx-auto">
          Everything you need to feel supported and informed during your pregnancy
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mt-10">
          {features.map((feature, index) => (
            <div
              key={index}
              className="flex items-start gap-5 bg-white p-6 rounded-2xl shadow-sm transition-all duration-300 hover:translate-x-2 hover:shadow-md"
            >
              <span className="text-3xl flex-shrink-0">{feature.icon}</span>
              <div>
                <h4 className="text-lg font-semibold text-text-dark mb-2">
                  {feature.title}
                </h4>
                <p className="text-sm text-text-light leading-relaxed">
                  {feature.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default AdditionalFeatures

