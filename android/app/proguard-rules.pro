# sun.misc.Cleanerに関する警告を無視
-dontwarn sun.misc.Cleaner
-dontwarn com.sun.xml.internal.ws.encoding.soap.SerializationException

# JLargeArraysのクラスは削除しないでね（必要に応じて）
-keep class pl.edu.icm.** { *; }
