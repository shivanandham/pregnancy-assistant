import { useEffect, useRef } from 'react'

const Hero = () => {
  const heroRef = useRef(null)

  useEffect(() => {
    // Add animated background pattern
    const hero = heroRef.current
    if (hero) {
      const style = document.createElement('style')
      style.textContent = `
        .hero-bg::before {
          content: '';
          position: absolute;
          top: -50%;
          right: -50%;
          width: 200%;
          height: 200%;
          background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
          background-size: 50px 50px;
          animation: float 20s ease-in-out infinite;
          opacity: 0.3;
          pointer-events: none;
        }
        
        @keyframes float {
          0%, 100% { transform: translate(0, 0) rotate(0deg); }
          50% { transform: translate(-30px, -30px) rotate(5deg); }
        }
      `
      document.head.appendChild(style)
    }
  }, [])

  return (
    <section 
      ref={heroRef}
      className="hero-bg min-h-screen flex items-center justify-center px-5 py-20 relative overflow-hidden"
      style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}
    >
      <div className="max-w-6xl w-full text-center relative z-10">
        {/* Logo */}
        <div className="mb-8 animate-[fadeInDown_0.8s_ease-out]">
          <div className="w-32 h-32 md:w-36 md:h-36 mx-auto flex items-center justify-center bg-white/95 rounded-full shadow-2xl p-5 transition-transform hover:scale-105 hover:rotate-6">
            <svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" className="w-full h-full">
              <defs>
                <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style={{ stopColor: '#FFB6C1', stopOpacity: 1 }} />
                  <stop offset="100%" style={{ stopColor: '#FFC0CB', stopOpacity: 1 }} />
                </linearGradient>
                <linearGradient id="heartGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style={{ stopColor: '#FF69B4', stopOpacity: 1 }} />
                  <stop offset="100%" style={{ stopColor: '#FF1493', stopOpacity: 1 }} />
                </linearGradient>
              </defs>
              <circle cx="256" cy="256" r="240" fill="url(#bgGradient)" stroke="#FFB6C1" strokeWidth="8"/>
              <path d="M256,400 C256,400 200,350 200,280 C200,250 220,230 250,230 C260,230 270,235 276,245 C282,235 292,230 302,230 C332,230 352,250 352,280 C352,350 296,400 256,400 Z" fill="url(#heartGradient)"/>
              <path d="M256,320 C256,320 240,310 240,290 C240,280 245,275 250,275 C252,275 254,276 255,278 C256,276 258,275 260,275 C265,275 270,280 270,290 C270,310 254,320 256,320 Z" fill="#FFFFFF" opacity="0.8"/>
              <circle cx="180" cy="180" r="4" fill="#FFFFFF" opacity="0.9"/>
              <circle cx="340" cy="160" r="3" fill="#FFFFFF" opacity="0.7"/>
              <circle cx="160" cy="320" r="3" fill="#FFFFFF" opacity="0.8"/>
              <circle cx="360" cy="340" r="4" fill="#FFFFFF" opacity="0.6"/>
              <circle cx="200" cy="120" r="2" fill="#FFFFFF" opacity="0.8"/>
              <circle cx="320" cy="380" r="2" fill="#FFFFFF" opacity="0.7"/>
            </svg>
          </div>
        </div>

        {/* Title */}
        <h1 className="text-6xl md:text-7xl font-extrabold mb-5 text-white text-shadow animate-[fadeInUp_0.8s_ease-out_0.2s_both]">
          Luma
        </h1>
        
        {/* Tagline */}
        <p className="text-2xl md:text-3xl text-white/95 mb-8 font-light animate-[fadeInUp_0.8s_ease-out_0.4s_both]">
          Your AI-Powered Pregnancy Companion
        </p>
        
        {/* Description */}
        <p className="text-lg md:text-xl text-white/90 max-w-3xl mx-auto mb-12 leading-relaxed animate-[fadeInUp_0.8s_ease-out_0.6s_both]">
          Luma is a comprehensive pregnancy tracking and AI assistant app designed to support 
          expecting mothers throughout their pregnancy journey. Get personalized guidance, 
          health monitoring, and educational content tailored to your pregnancy week.
        </p>
        
        {/* CTA Button */}
        <a 
          href="#download" 
          className="inline-block px-10 py-4 bg-white text-accent rounded-full text-lg font-semibold shadow-xl transition-all hover:-translate-y-1 hover:shadow-2xl animate-[fadeInUp_0.8s_ease-out_0.8s_both]"
        >
          Get Started
        </a>
      </div>

      <style>{`
        @keyframes fadeInDown {
          from { opacity: 0; transform: translateY(-30px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(30px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </section>
  )
}

export default Hero

