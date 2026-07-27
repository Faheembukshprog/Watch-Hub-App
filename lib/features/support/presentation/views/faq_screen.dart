import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FAQTile(
            question: 'Are the watches authentic?',
            answer: 'Yes, every timepiece in our collection is 100% authentic and comes with a certificate of authenticity and the original manufacturer warranty.',
          ),
          _FAQTile(
            question: 'How long does shipping take?',
            answer: 'We offer worldwide express shipping. Domestic orders typically arrive within 2-3 business days, while international orders take 5-7 business days.',
          ),
          _FAQTile(
            question: 'What is your return policy?',
            answer: 'We offer a 14-day return policy for unworn watches in their original condition and packaging. Please contact support to initiate a return.',
          ),
          _FAQTile(
            question: 'Do you offer servicing?',
            answer: 'Yes, we have a network of certified watchmakers who can service your timepiece. Contact us for a quote and shipping instructions.',
          ),
        ],
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
