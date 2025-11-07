import '../model/quiz_question.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  static final Map<String, List<QuizQuestion>> quizzesByLesson = {
    // Basics - What is the Stock Market?
    'What is the Stock Market?': [
      QuizQuestion(
        id: 'basics_1_1',
        question: 'What is a stock?',
        options: [
          'A type of currency',
          'A share of ownership in a company',
          'A loan to a company',
          'A government bond',
        ],
        correctAnswerIndex: 1,
        explanation: 'A stock represents ownership in a company. When you buy a stock, you become a partial owner (shareholder) of that company.',
        category: 'Basics',
        lessonId: 'What is the Stock Market?',
      ),
      QuizQuestion(
        id: 'basics_1_2',
        question: 'What is the primary purpose of the stock market?',
        options: [
          'To buy and sell currencies',
          'To allow companies to raise capital and investors to buy ownership',
          'To trade commodities',
          'To store money securely',
        ],
        correctAnswerIndex: 1,
        explanation: 'The stock market allows companies to raise capital by selling shares, and investors can buy ownership in these companies.',
        category: 'Basics',
        lessonId: 'What is the Stock Market?',
      ),
      QuizQuestion(
        id: 'basics_1_3',
        question: 'What happens when you buy a stock?',
        options: [
          'You lend money to the company',
          'You become a partial owner of the company',
          'You receive a fixed interest payment',
          'The company owes you money',
        ],
        correctAnswerIndex: 1,
        explanation: 'Buying a stock makes you a shareholder, giving you partial ownership and potential voting rights in the company.',
        category: 'Basics',
        lessonId: 'What is the Stock Market?',
      ),
    ],

    // Basics - Types of Stocks
    'Types of Stocks': [
      QuizQuestion(
        id: 'basics_2_1',
        question: 'What is a growth stock?',
        options: [
          'A stock that pays high dividends',
          'A stock expected to grow faster than the market average',
          'A stock with stable prices',
          'A government-backed stock',
        ],
        correctAnswerIndex: 1,
        explanation: 'Growth stocks are from companies expected to grow revenue and earnings faster than the market average, often reinvesting profits instead of paying dividends.',
        category: 'Basics',
        lessonId: 'Types of Stocks',
      ),
      QuizQuestion(
        id: 'basics_2_2',
        question: 'What is a dividend stock?',
        options: [
          'A stock that never changes price',
          'A stock that pays regular cash payments to shareholders',
          'A stock that grows very fast',
          'A stock only for beginners',
        ],
        correctAnswerIndex: 1,
        explanation: 'Dividend stocks pay regular cash distributions (dividends) to shareholders, typically from mature, profitable companies.',
        category: 'Basics',
        lessonId: 'Types of Stocks',
      ),
      QuizQuestion(
        id: 'basics_2_3',
        question: 'What is a value stock?',
        options: [
          'A stock that is overpriced',
          'A stock trading below its intrinsic value',
          'A stock with no growth potential',
          'A stock that pays no dividends',
        ],
        correctAnswerIndex: 1,
        explanation: 'Value stocks are trading at a price below what analysts believe they\'re worth, often from established companies with steady earnings.',
        category: 'Basics',
        lessonId: 'Types of Stocks',
      ),
    ],

    // Basics - Reading Stock Charts
    'Reading Stock Charts': [
      QuizQuestion(
        id: 'basics_3_1',
        question: 'What does a green/upward candlestick indicate?',
        options: [
          'The stock price decreased',
          'The stock price increased',
          'No price change',
          'Trading was halted',
        ],
        correctAnswerIndex: 1,
        explanation: 'A green or upward candlestick shows the closing price was higher than the opening price, indicating a price increase.',
        category: 'Basics',
        lessonId: 'Reading Stock Charts',
      ),
      QuizQuestion(
        id: 'basics_3_2',
        question: 'What does volume represent on a stock chart?',
        options: [
          'The stock price',
          'The number of shares traded',
          'The company\'s revenue',
          'The time of day',
        ],
        correctAnswerIndex: 1,
        explanation: 'Volume shows how many shares were traded during a period. High volume often indicates strong interest in a stock.',
        category: 'Basics',
        lessonId: 'Reading Stock Charts',
      ),
      QuizQuestion(
        id: 'basics_3_3',
        question: 'What is a moving average?',
        options: [
          'The current stock price',
          'The average price over a specific period',
          'The highest price ever',
          'The dividend yield',
        ],
        correctAnswerIndex: 1,
        explanation: 'A moving average smooths out price data by calculating the average price over a specific time period, helping identify trends.',
        category: 'Basics',
        lessonId: 'Reading Stock Charts',
      ),
    ],

    // Basics - Market Orders vs Limit Orders
    'Market Orders vs Limit Orders': [
      QuizQuestion(
        id: 'basics_4_1',
        question: 'What is a market order?',
        options: [
          'An order to buy/sell at a specific price',
          'An order to buy/sell immediately at current market price',
          'An order that only executes at market open',
          'An order with special conditions',
        ],
        correctAnswerIndex: 1,
        explanation: 'A market order executes immediately at the current market price, ensuring quick execution but no price guarantee.',
        category: 'Basics',
        lessonId: 'Market Orders vs Limit Orders',
      ),
      QuizQuestion(
        id: 'basics_4_2',
        question: 'What is a limit order?',
        options: [
          'An order that executes immediately',
          'An order to buy/sell only at a specific price or better',
          'An order with no price limit',
          'An order that expires immediately',
        ],
        correctAnswerIndex: 1,
        explanation: 'A limit order only executes at your specified price or better, giving you price control but no guarantee of execution.',
        category: 'Basics',
        lessonId: 'Market Orders vs Limit Orders',
      ),
      QuizQuestion(
        id: 'basics_4_3',
        question: 'When should you use a limit order?',
        options: [
          'When you need immediate execution',
          'When you want to control the price you pay/receive',
          'When the market is closed',
          'When you don\'t care about price',
        ],
        correctAnswerIndex: 1,
        explanation: 'Use a limit order when price matters more than immediate execution. It ensures you don\'t pay more (or receive less) than your limit.',
        category: 'Basics',
        lessonId: 'Market Orders vs Limit Orders',
      ),
    ],

    // Basics - Bull vs Bear Markets
    'Bull vs Bear Markets': [
      QuizQuestion(
        id: 'basics_5_1',
        question: 'What is a bull market?',
        options: [
          'A market where prices are falling',
          'A market where prices are rising',
          'A market with no movement',
          'A market only for large investors',
        ],
        correctAnswerIndex: 1,
        explanation: 'A bull market is characterized by rising stock prices and investor optimism, typically lasting for months or years.',
        category: 'Basics',
        lessonId: 'Bull vs Bear Markets',
      ),
      QuizQuestion(
        id: 'basics_5_2',
        question: 'What is a bear market?',
        options: [
          'A market where prices are rising',
          'A market where prices are falling',
          'A market for commodity trading',
          'A new type of market',
        ],
        correctAnswerIndex: 1,
        explanation: 'A bear market features falling stock prices and investor pessimism, typically defined as a 20% decline from recent highs.',
        category: 'Basics',
        lessonId: 'Bull vs Bear Markets',
      ),
      QuizQuestion(
        id: 'basics_5_3',
        question: 'What should you consider during a bear market?',
        options: [
          'Only buy high-risk stocks',
          'Panic and sell everything',
          'Stay calm, consider buying opportunities, and review your strategy',
          'Stop investing completely',
        ],
        correctAnswerIndex: 2,
        explanation: 'During bear markets, stay disciplined. Review your strategy, consider buying opportunities at lower prices, and maintain diversification.',
        category: 'Basics',
        lessonId: 'Bull vs Bear Markets',
      ),
    ],

    // Basics - Building Your First Portfolio
    'Building Your First Portfolio': [
      QuizQuestion(
        id: 'basics_6_1',
        question: 'What is diversification?',
        options: [
          'Putting all money in one stock',
          'Spreading investments across different assets to reduce risk',
          'Trading stocks frequently',
          'Only investing in tech stocks',
        ],
        correctAnswerIndex: 1,
        explanation: 'Diversification means spreading investments across different stocks, sectors, and asset types to reduce the impact of any single investment\'s poor performance.',
        category: 'Basics',
        lessonId: 'Building Your First Portfolio',
      ),
      QuizQuestion(
        id: 'basics_6_2',
        question: 'Why is diversification important?',
        options: [
          'It guarantees profits',
          'It reduces risk by not putting all eggs in one basket',
          'It increases trading fees',
          'It makes taxes simpler',
        ],
        correctAnswerIndex: 1,
        explanation: 'Diversification reduces risk because if one investment performs poorly, others may perform well, balancing your overall portfolio.',
        category: 'Basics',
        lessonId: 'Building Your First Portfolio',
      ),
      QuizQuestion(
        id: 'basics_6_3',
        question: 'What is asset allocation?',
        options: [
          'Selling all your assets',
          'How you divide your investments among different asset types',
          'Calculating taxes',
          'Tracking daily prices',
        ],
        correctAnswerIndex: 1,
        explanation: 'Asset allocation is the strategy of dividing your investments among different categories (stocks, bonds, cash) based on your goals and risk tolerance.',
        category: 'Basics',
        lessonId: 'Building Your First Portfolio',
      ),
    ],
  };

  List<QuizQuestion> getQuizForLesson(String lessonTitle) {
    return quizzesByLesson[lessonTitle] ?? [];
  }

  bool hasQuizForLesson(String lessonTitle) {
    return quizzesByLesson.containsKey(lessonTitle) && 
           quizzesByLesson[lessonTitle]!.isNotEmpty;
  }

  List<String> getLessonsWithQuizzes() {
    return quizzesByLesson.keys.toList();
  }
}

