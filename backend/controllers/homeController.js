const prisma = require('../lib/prisma');

class HomeController {
  // Calculate current pregnancy week
  static calculateCurrentWeek(lastMenstrualPeriod) {
    if (!lastMenstrualPeriod) return null;
    
    const lmp = new Date(lastMenstrualPeriod);
    const today = new Date();
    const diffTime = today - lmp;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    const currentWeek = Math.floor(diffDays / 7);
    
    return Math.max(0, currentWeek);
  }

  // Get all home screen data
  static async getHomeData(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Get current pregnancy data to determine the week
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId }
      });
      
      if (!pregnancy) {
        return res.json({
          success: true,
          data: {
            hasPregnancyData: false,
            message: 'No pregnancy data found. Please set up your pregnancy information.'
          }
        });
      }

      const currentWeek = HomeController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      
      res.json({
        success: true,
        data: {
          hasPregnancyData: true,
          currentWeek: currentWeek,
          pregnancy: pregnancy
        }
      });
    } catch (error) {
      console.error('Error getting home data:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

}

module.exports = HomeController;
