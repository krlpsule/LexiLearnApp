import 'package:flutter/material.dart';
import 'language_manager.dart';

class LanguageSlider extends StatelessWidget {
  const LanguageSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        bool isTr = lang == 'tr';
        return GestureDetector(
          onTap: () {
            // Toggles language between 'en' and 'tr'
            LanguageManager.currentLang.value = isTr ? 'en' : 'tr';
          },
          child: Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                // The sliding blue indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: isTr ? 40 : 2, // Slides to the right for TR
                  right: isTr ? 2 : 40,
                  top: 2,
                  bottom: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                // The text labels (EN and TR)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('EN', style: TextStyle(
                            color: !isTr ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold
                        )),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('TR', style: TextStyle(
                            color: isTr ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          );
        },
    );
  }
}