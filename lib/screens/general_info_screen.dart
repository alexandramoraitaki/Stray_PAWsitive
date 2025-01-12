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
                        'Οι σκύλοι είναι οι πιο πιστοί μας φίλοι και χρειάζονται τη σωστή φροντίδα για να ζουν χαρούμενοι και υγιείς. '
                        'Αν συναντήσετε ένα αδέσποτο σκυλάκι στο δρόμο, να θυμάστε ότι μπορεί να είναι φοβισμένο ή μπερδεμένο. '
                        'Προσεγγίστε το αργά, αφήστε το να σας μυρίσει και δείξτε του ότι δεν αποτελείτε απειλή. '
                        'Πάντα να έχετε μαζί σας λίγη υπομονή – και φυσικά λίγο φρέσκο νερό! 💧\n\n'
                        'Όσον αφορά την τροφή, αν δεν έχετε σκυλοτροφή, μην ανησυχείτε! Ένα κομματάκι ψωμί, λίγο ρύζι, '
                        'ή ακόμη και καρότα και μήλα (χωρίς κουκούτσια) είναι εξαιρετικές και ασφαλείς επιλογές! 🥕🍎\n\n'
                        'Προσοχή! Αποφύγετε εντελώς τη σοκολάτα, τα σταφύλια, τον καφέ, το αλκοόλ ή οποιοδήποτε τρόφιμο '
                        'περιέχει ζύμη με μαγιά, καθώς όλα αυτά είναι τοξικά για τους μικρούς μας φίλους!\n\n'
                        'Αν το σκυλάκι φαίνεται τραυματισμένο, είναι σημαντικό να δράσετε άμεσα. '
                        'Επικοινωνήστε με έναν κτηνίατρο ή κάποιον φορέα φιλοζωίας (μπορείτε να βρείτε σχετικές πληροφορίες '
                        'στον χάρτη της εφαρμογής μας). Θυμηθείτε επίσης ότι η ουρά του δεν είναι πάντα ένδειξη χαράς – '
                        'μπορεί να δείχνει άγχος ή φόβο, οπότε προσεγγίστε το με προσοχή. 🐶\n\n'
                        'Δείξτε του αγάπη, δώστε του λίγο χρόνο και φροντίδα, κι ίσως κερδίσετε έναν φίλο για μια ζωή! 💕',
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
                        'Οι γάτες είναι οι αριστοκράτισσες του ζωικού βασιλείου – γεμάτες μυστήριο και γοητεία. '
                        '🐾 Αν συναντήσετε μια αδέσποτη γάτα, θυμηθείτε πως κάθε ζωάκι έχει τη δική του προσωπικότητα. '
                        'Αφήστε την να πάρει τον χρόνο της και να κάνει εκείνη την πρώτη κίνηση για να σας πλησιάσει! 💕\n\n'
                        'Οι γάτες είναι λάτρεις της πρωτεΐνης! Αν έχετε λίγη γατοτροφή ή μαγειρεμένο κοτόπουλο '
                        '(χωρίς μπαχαρικά και πρόσθετα), σίγουρα θα τραβήξετε την προσοχή τους! Αν αυτά δεν είναι διαθέσιμα, '
                        'εξίσου ασφαλείς και νόστιμες επιλογές είναι λίγο ρύζι, ψίχουλα από ψωμί, μια φέτα ζαμπόν χωρίς πρόσθετα '
                        'ή ακόμη και λίγο βρασμένο αυγό (χωρίς το κέλυφος). Όλα αυτά είναι τροφές που μπορείτε να βρείτε εύκολα '
                        'στο σπίτι σας ή στο κοντινότερο σούπερ μάρκετ!\n\n'
                        'Προσοχή! Αποφύγετε εντελώς το γάλα, όσο κι αν οι γάτες στα κινούμενα σχέδια το λατρεύουν – '
                        'πολλές γατούλες έχουν δυσανεξία στη λακτόζη! Αντίθετα, ένα μπολάκι με φρέσκο νερό είναι η καλύτερη '
                        'επιλογή για να τις κρατήσετε ενυδατωμένες! 💧\n\n'
                        'Αν η γατούλα φαίνεται τραυματισμένη ή φοβισμένη, δοκιμάστε να τη σκεπάσετε απαλά με ένα ύφασμα '
                        'για να την ηρεμήσετε. Έτσι θα νιώσει πιο ασφαλής. Στη συνέχεια, επικοινωνήστε με έναν κτηνίατρο '
                        'ή κάποιον οργανισμό φιλοζωίας (ο χάρτης της εφαρμογής μας είναι εδώ για να σας βοηθήσει!). 😺\n\n'
                        'Οι γάτες αγαπούν την ανεξαρτησία τους, αλλά αν κερδίσετε την εμπιστοσύνη τους, θα βρείτε έναν '
                        'ξεχωριστό φίλο που θα σας προσφέρει ατελείωτες στιγμές στοργής – και, φυσικά, λίγη από τη '
                        'χαρακτηριστική «γάτο-υπεροψία» τους! 💖',
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
                      'Δεν βρήκατε αυτό που ψάχνατε; Μην διστάσετε να συνομιλήσετε με το μποτάκι μας! '
                      'Είναι πάντα έτοιμο να σας καθοδηγήσει με εξειδικευμένες πληροφορίες για τη φροντίδα των φίλων μας. 🐾💬',
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
