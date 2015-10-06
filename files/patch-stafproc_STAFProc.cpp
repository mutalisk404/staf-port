--- stafproc/STAFProc.cpp.orig	2015-09-28 13:34:21 UTC
+++ stafproc/STAFProc.cpp
@@ -487,9 +487,7 @@ int main(int argc, char **argv, char **e
     }
     else
     {
-        configFile = STAFString(configInfo.exePath) +
-                     STAFString(configInfo.fileSeparator) + "bin" +
-                     STAFString(configInfo.fileSeparator) + "STAF.cfg";
+        configFile = "%%PREFIX%%/etc/STAF.cfg";
     }
 
     // Set environment buffer for use by Process service
