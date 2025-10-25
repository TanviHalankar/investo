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
      appBar: AppBar(
        title: const Text('Your Portfolio'),
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
              const SizedBox(height: 16),
              if (holdings.isEmpty)
                _emptyHoldingsCard()
              else ...[
                const Text('Holdings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                ...holdings.map(_holdingTile),
              ],
              const SizedBox(height: 16),
              const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              ...state.transactions.map(_txTile),
              const SizedBox(height: 32),
              _resetButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(PortfolioState s) {
    final pnlColor = s.totalPnL >= 0 ? Colors.green : Colors.red;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Total Value', style: TextStyle(color: Colors.grey[700]))),
                Text(_fmt.format(s.totalValue), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Cash Balance', style: TextStyle(color: Colors.grey[700]))),
                Text(_fmt.format(s.cashBalance), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Invested', style: TextStyle(color: Colors.grey[700]))),
                Text(_fmt.format(s.invested), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('P&L', style: TextStyle(color: Colors.grey[700]))),
                Text(
                  '${s.totalPnL >= 0 ? '+' : ''}${_fmt.format(s.totalPnL)}',
                  style: TextStyle(fontWeight: FontWeight.w700, color: pnlColor),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Points: ${s.points}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                const Text('Tip: Earn points with every trade!', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _holdingTile(Holding h) {
    final pnlColor = h.pnl >= 0 ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        title: Text('${h.symbol} · ${h.name}', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${h.quantity} @ ${_fmt.format(h.avgPrice)}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_fmt.format(h.marketValue), style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              '${h.pnl >= 0 ? '+' : ''}${h.pnl.toStringAsFixed(2)} (${h.pnlPercent.toStringAsFixed(2)}%)',
              style: TextStyle(color: pnlColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _txTile(TransactionItem t) {
    final isBuy = t.action == 'BUY';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBuy ? Colors.green[100] : Colors.red[100],
          child: Icon(isBuy ? Icons.add : Icons.remove, color: isBuy ? Colors.green : Colors.red),
        ),
        title: Text('${t.action} ${t.symbol} · ${t.quantity} x ${_fmt.format(t.price)}'),
        subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(t.timestamp)),
        trailing: Text(_fmt.format(t.total), style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _emptyHoldingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            Icon(Icons.info_outline),
            SizedBox(width: 12),
            Expanded(child: Text('Your holdings will appear here after you place BUY orders.')),
          ],
        ),
      ),
    );
  }

  Widget _resetButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await _service.reset();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portfolio reset to demo balance')),
          );
        },
        icon: const Icon(Icons.restart_alt),
        label: const Text('Reset Demo Portfolio'),
      ),
    );
  }
}
