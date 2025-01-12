import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'bot_screen.dart';

class GeneralInfoScreen extends StatelessWidget {
  const GeneralInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Logo πάνω δεξιά
          Positioned(
            top: 20,
            left: 310,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              child: Image.asset(
                'assets/logo/logo.png',
                height: 60,
              ),
            ),
          ),

          // Πίσω βέλος πάνω αριστερά
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Κύριο περιεχόμενο σε scroll
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  const SizedBox(height: 120),

                  // Τίτλος "General Info"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E1),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'General Info',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Επικεφαλίδα "DOG"
                  Container(
                    width: screenWidth * 0.7,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(
                      child: Text(
                        'DOG',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Πλαίσιο "DOG Info"
                  Container(
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const SingleChildScrollView(
                      child: Text(
                        'Dogs are our most loyal friends and need the right care to live happy and healthy lives. '
                        'If you encounter a stray dog on the street, remember that it might be scared or confused. '
                        'Approach it slowly, let it sniff you, and show it that you’re not a threat. '
                        'Always have a little patience – and, of course, some fresh water! 💧\n\n'
                        'If you don’t have dog food, don’t worry! A piece of bread, some rice, '
                        'or even carrots and apples (without seeds) are excellent and safe options! 🥕🍎\n\n'
                        'Caution! Completely avoid chocolate, grapes, coffee, alcohol, or any food containing yeast dough, '
                        'as these are toxic for our furry friends!\n\n'
                        'If the dog seems injured, it’s important to act quickly. '
                        'Contact a veterinarian or an animal welfare organization (you can find relevant information '
                        'on the map in our app). Also, remember that a wagging tail isn’t always a sign of happiness – '
                        'it could indicate anxiety or fear, so approach with care. 🐶\n\n'
                        'Show it love, give it some time and care, and you might just gain a friend for life! 💕',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Επικεφαλίδα "CAT"
                  Container(
                    width: screenWidth * 0.7,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Center(
                      child: Text(
                        'CAT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Πλαίσιο "CAT Info"
                  Container(
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const SingleChildScrollView(
                      child: Text(
                        'Cats are the aristocrats of the animal kingdom – full of mystery and charm. 🐾 '
                        'If you come across a stray cat, remember that every little creature has its own personality. '
                        'Give them time and let them make the first move to approach you! 💕\n\n'
                        'Cats are protein lovers! If you have some cat food or cooked chicken (without spices or additives), '
                        'you’re sure to grab their attention! If these aren’t available, equally safe and tasty options include '
                        'a bit of rice, breadcrumbs, a slice of plain ham, or even a little boiled egg (without the shell). '
                        'These are foods you can easily find at home or at your nearest supermarket!\n\n'
                        'Caution! Avoid giving them milk, no matter how much cartoon cats seem to love it – '
                        'many cats are lactose intolerant! Instead, a bowl of fresh water is the best way to keep them hydrated! 💧\n\n'
                        'If the cat appears injured or scared, try gently covering them with a cloth to help calm them. '
                        'This will make them feel safer. Then, contact a vet or an animal welfare organization '
                        '(the map in our app is here to help you!). 😺\n\n'
                        'Cats love their independence, but if you earn their trust, you’ll find a unique companion who will offer you '
                        'endless moments of affection – and, of course, a little of their signature “cat superiority”! 💖',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Τελικό Πλαίσιο
                  Container(
                    width: screenWidth * 0.8,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Didn’t find what you were looking for? Don’t hesitate to chat with our little bot! '
                      'It’s always ready to guide you with specialized information about caring for our furry friends. 🐾💬',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Dog Bot κάτω δεξιά
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BotScreen()),
                );
              },
              child: Image.asset(
                'assets/icons/bot.png',
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
