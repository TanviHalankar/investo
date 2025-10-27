// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/portfolio_service.dart';
// import '../services/guide_service.dart';
//
// class PortfolioScreen extends StatefulWidget {
//   const PortfolioScreen({super.key});
//
//   @override
//   State<PortfolioScreen> createState() => _PortfolioScreenState();
// }
//
// class _PortfolioScreenState extends State<PortfolioScreen> {
//   final _service = PortfolioService();
//   final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//   @override
//   Widget build(BuildContext context) {
//     // show intro once
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       GuideService().show(const GuideStep(
//         id: 'portfolio_intro',
//         title: 'Track your progress',
//         message: 'This Portfolio shows cash, holdings, and P&L. Your points and rank grow as you trade.',
//       ));
//     });
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Portfolio'),
//       ),
//       body: StreamBuilder<PortfolioState>(
//         stream: _service.stream,
//         initialData: _service.state,
//         builder: (context, snapshot) {
//           final state = snapshot.data!;
//           final holdings = state.holdings.values.toList()..sort((a, b) => a.symbol.compareTo(b.symbol));
//
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               _summaryCard(state),
//               const SizedBox(height: 16),
//               if (holdings.isEmpty)
//                 _emptyHoldingsCard()
//               else ...[
//                 const Text('Holdings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//                 const SizedBox(height: 8),
//                 ...holdings.map(_holdingTile),
//               ],
//               const SizedBox(height: 16),
//               const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
//               const SizedBox(height: 8),
//               ...state.transactions.map(_txTile),
//               const SizedBox(height: 32),
//               _resetButton(),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _summaryCard(PortfolioState s) {
//     final pnlColor = s.totalPnL >= 0 ? Colors.green : Colors.red;
//     return Card(
//       elevation: 1,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(child: Text('Total Value', style: TextStyle(color: Colors.grey[700]))),
//                 Text(_fmt.format(s.totalValue), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: Text('Cash Balance', style: TextStyle(color: Colors.grey[700]))),
//                 Text(_fmt.format(s.cashBalance), style: const TextStyle(fontWeight: FontWeight.w600)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: Text('Invested', style: TextStyle(color: Colors.grey[700]))),
//                 Text(_fmt.format(s.invested), style: const TextStyle(fontWeight: FontWeight.w600)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: Text('P&L', style: TextStyle(color: Colors.grey[700]))),
//                 Text(
//                   '${s.totalPnL >= 0 ? '+' : ''}${_fmt.format(s.totalPnL)}',
//                   style: TextStyle(fontWeight: FontWeight.w700, color: pnlColor),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             Row(
//               children: [
//                 const Icon(Icons.emoji_events, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 Text('Points: ${s.points}', style: const TextStyle(fontWeight: FontWeight.w700)),
//                 const Spacer(),
//                 const Text('Tip: Earn points with every trade!', style: TextStyle(color: Colors.grey)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _holdingTile(Holding h) {
//     final pnlColor = h.pnl >= 0 ? Colors.green : Colors.red;
//     return Card(
//       child: ListTile(
//         title: Text('${h.symbol} · ${h.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
//         subtitle: Text('${h.quantity} @ ${_fmt.format(h.avgPrice)}'),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_fmt.format(h.marketValue), style: const TextStyle(fontWeight: FontWeight.w700)),
//             Text(
//               '${h.pnl >= 0 ? '+' : ''}${h.pnl.toStringAsFixed(2)} (${h.pnlPercent.toStringAsFixed(2)}%)',
//               style: TextStyle(color: pnlColor, fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _txTile(TransactionItem t) {
//     final isBuy = t.action == 'BUY';
//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: isBuy ? Colors.green[100] : Colors.red[100],
//           child: Icon(isBuy ? Icons.add : Icons.remove, color: isBuy ? Colors.green : Colors.red),
//         ),
//         title: Text('${t.action} ${t.symbol} · ${t.quantity} x ${_fmt.format(t.price)}'),
//         subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(t.timestamp)),
//         trailing: Text(_fmt.format(t.total), style: const TextStyle(fontWeight: FontWeight.w700)),
//       ),
//     );
//   }
//
//   Widget _emptyHoldingsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: const [
//             Icon(Icons.info_outline),
//             SizedBox(width: 12),
//             Expanded(child: Text('Your holdings will appear here after you place BUY orders.')),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _resetButton() {
//     return Center(
//       child: TextButton.icon(
//         onPressed: () async {
//           await _service.reset();
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Portfolio reset to demo balance')),
//           );
//         },
//         icon: const Icon(Icons.restart_alt),
//         label: const Text('Reset Demo Portfolio'),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/portfolio_service.dart';
import '../services/guide_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _service = PortfolioService();
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // Modern dark color scheme with orange accents (matching home screen)
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  @override
  Widget build(BuildContext context) {
    // show intro once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideService().show(const GuideStep(
        id: 'portfolio_intro',
        title: 'Track your progress',
        message: 'This Portfolio shows cash, holdings, and P&L. Your points and rank grow as you trade.',
      ));
    });
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          'Your Portfolio',
          style: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      body: StreamBuilder<PortfolioState>(
        stream: _service.stream,
        initialData: _service.state,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          final holdings = state.holdings.values.toList()..sort((a, b) => a.symbol.compareTo(b.symbol));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(state),
              const SizedBox(height: 24),
              if (holdings.isEmpty)
                _emptyHoldingsCard()
              else ...[
                const Text(
                  'Holdings',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...holdings.map(_holdingTile),
              ],
              const SizedBox(height: 24),
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              ...state.transactions.map(_txTile),
              const SizedBox(height: 32),
              // _resetButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(PortfolioState s) {
    final pnlColor = s.totalPnL >= 0 ? positiveGreen : negativeRed;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardDark, cardLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Value',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                _fmt.format(s.totalValue),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cash Balance',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                _fmt.format(s.cashBalance),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invested',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                _fmt.format(s.invested),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'P&L',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '${s.totalPnL >= 0 ? '+' : ''}${_fmt.format(s.totalPnL)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: pnlColor,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: borderColor),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: accentOrange, size: 24),
              const SizedBox(width: 12),
              Text(
                'Points: ${s.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                'Earn points with every trade!',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _holdingTile(Holding h) {
    final pnlColor = h.pnl >= 0 ? positiveGreen : negativeRed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${h.symbol} · ${h.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${h.quantity} @ ${_fmt.format(h.avgPrice)}',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _fmt.format(h.marketValue),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  fontSize: 18,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: h.pnl >= 0 ? positiveGreen.withOpacity(0.15) : negativeRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${h.pnl >= 0 ? '+' : ''}${h.pnl.toStringAsFixed(2)} (${h.pnlPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _txTile(TransactionItem t) {
    final isBuy = t.action == 'BUY';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isBuy ? positiveGreen.withOpacity(0.15) : negativeRed.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBuy ? Icons.add_rounded : Icons.remove_rounded,
              color: isBuy ? positiveGreen : negativeRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.action} ${t.symbol} · ${t.quantity} x ${_fmt.format(t.price)}',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(t.timestamp),
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _fmt.format(t.total),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: textPrimary,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHoldingsCard() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 56,
              color: textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No holdings yet',
              style: TextStyle(
                color: textSecondary,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your holdings will appear here after you place BUY orders.',
              style: TextStyle(
                color: textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _resetButton() {
  //   return Center(
  //     child: Container(
  //       height: 48,
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [accentOrange, accentOrangeDim],
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: accentOrange.withOpacity(0.3),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: ElevatedButton.icon(
  //         onPressed: () async {
  //           await _service.reset();
  //           if (!mounted) return;
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text(
  //                 'Portfolio reset to demo balance',
  //                 style: TextStyle(
  //                   color: textPrimary,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //               backgroundColor: cardDark,
  //               behavior: SnackBarBehavior.floating,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //           );
  //         },
  //         icon: const Icon(Icons.restart_alt, color: darkBg),
  //         label: const Text(
  //           'Reset Demo Portfolio',
  //           style: TextStyle(
  //             fontSize: 15,
  //             fontWeight: FontWeight.w700,
  //             letterSpacing: 0.5,
  //             color: darkBg,
  //           ),
  //         ),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           shadowColor: Colors.transparent,
  //           padding: const EdgeInsets.symmetric(horizontal: 24),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}