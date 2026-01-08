# Ignoriraj ML Kit klase za jezike koje ne koristimo
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Zadrži potrebne klase da ih R8 ne obriše greškom
-keep class com.google.mlkit.vision.text.** { *; }