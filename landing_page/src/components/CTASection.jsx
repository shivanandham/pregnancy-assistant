import { useReleaseInfo } from '../hooks/useReleaseInfo'

const CTASection = () => {
  const { loading, releaseInfo, error, refetch } = useReleaseInfo()

  return (
    <section 
      id="download" 
      className="py-24 px-5 text-center text-white"
      style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}
    >
      <h2 className="text-4xl md:text-6xl font-bold mb-5">
        Start Your Journey Today
      </h2>
      <p className="text-xl md:text-2xl mb-10 opacity-95 max-w-2xl mx-auto">
        Download Luma and begin tracking your pregnancy with confidence and ease
      </p>

      {/* Loading State */}
      {loading && (
        <div className="flex flex-col items-center gap-5 my-8">
          <div className="w-12 h-12 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>
          <p className="text-base opacity-90">Loading download information...</p>
        </div>
      )}

      {/* Release Info */}
      {releaseInfo && !loading && (
        <div className="flex gap-5 justify-center my-8 flex-wrap">
          <div className="bg-white/20 backdrop-blur-lg px-6 py-3 rounded-full border border-white/30 flex items-center gap-3">
            <span className="text-sm font-medium text-white/90">Latest Version:</span>
            <span className="text-base font-semibold text-white">{releaseInfo.version || 'Latest'}</span>
          </div>
          <div className="bg-white/20 backdrop-blur-lg px-6 py-3 rounded-full border border-white/30 flex items-center gap-3">
            <span className="text-sm font-medium text-white/90">Size:</span>
            <span className="text-base font-semibold text-white">{releaseInfo.formattedSize}</span>
          </div>
        </div>
      )}

      {/* Download Button */}
      {releaseInfo && !loading && (
        <a
          href={releaseInfo.download_url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-block px-10 py-4 bg-white text-accent rounded-full text-lg font-semibold shadow-xl transition-all hover:-translate-y-1 hover:shadow-2xl"
        >
          Download for Android
        </a>
      )}

      {/* Error Message */}
      {error && !loading && (
        <div className="bg-white/95 text-red-600 p-5 rounded-xl my-8 max-w-md mx-auto text-center">
          <p className="mb-4 text-base">{error}</p>
          <button
            onClick={refetch}
            className="bg-gray-200 text-gray-700 px-6 py-2 rounded-lg text-base font-semibold transition-all hover:bg-gray-300 hover:-translate-y-0.5"
          >
            Try Again
          </button>
        </div>
      )}
    </section>
  )
}

export default CTASection

