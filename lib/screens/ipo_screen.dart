import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IpoScreen extends StatelessWidget {
  const IpoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ipos = [
      {'name': 'Acme Tech', 'price': 120.0, 'date': 'Nov 10', 'subscription': 3.2},
      {'name': 'Green Energy', 'price': 85.0, 'date': 'Nov 12', 'subscription': 1.8},
      {'name': 'Urban Foods', 'price': 60.0, 'date': 'Nov 15', 'subscription': 5.4},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming IPOs')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ipos.length,
        itemBuilder: (context, index) {
          final ipo = ipos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(ipo['name'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      Text('Opens ${ipo['date']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Issue price: ₹${(ipo['price'] as double).toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),
                        barGroups: List.generate(5, (i) {
                          final mult = (ipo['subscription'] as double);
                          return BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: (1 + i * 0.5) * mult,
                              color: Colors.orange,
                              width: 12,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6), topRight: Radius.circular(6),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text('Current subscription: ${(ipo['subscription'] as double).toStringAsFixed(1)}x'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Prospectus'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Demo: IPO application coming soon')),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('Apply (Demo)'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
