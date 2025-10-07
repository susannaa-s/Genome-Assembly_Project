set terminal png tiny size 1400,1400
set output "/data/users/sschaerer/assembly_annotation_course/mummer_output/flye_vs_ref.png"
set xtics rotate ( \
 "1" 1.0, \
 "5" 30427671.0, \
 "3" 57403172.0, \
 "2" 80863001.0, \
 "4" 100561289.0, \
 "Mt" 119146344.0, \
 "Pt" 119513267.0, \
 "" 119667750 \
)
set ytics ( \
 "*contig_1" 1.0, \
 "contig_48" 10857970.0, \
 "contig_21" 14070342.0, \
 "contig_110" 14370563.0, \
 "contig_112" 14417127.0, \
 "contig_14" 14455534.0, \
 "*contig_11" 21344865.0, \
 "*contig_17" 29558805.0, \
 "*contig_85" 40895231.0, \
 "contig_45" 41122999.0, \
 "*contig_101" 41436434.0, \
 "contig_49" 41497926.0, \
 "contig_57" 41588940.0, \
 "*contig_105" 41638721.0, \
 "*contig_81" 41920971.0, \
 "contig_20" 42048203.0, \
 "contig_79" 42269272.0, \
 "*contig_106" 42528264.0, \
 "contig_108" 43135008.0, \
 "contig_18" 43506163.0, \
 "*contig_77" 44063915.0, \
 "contig_3" 44120443.0, \
 "contig_7" 49908047.0, \
 "contig_9" 54457438.0, \
 "*contig_47" 56676735.0, \
 "*contig_99" 59815552.0, \
 "*contig_22" 59846372.0, \
 "*contig_56" 69909737.0, \
 "*contig_103" 70075664.0, \
 "*contig_82" 70400057.0, \
 "*contig_74" 70790909.0, \
 "*contig_43" 70857328.0, \
 "*contig_42" 71061645.0, \
 "*contig_61" 74853182.0, \
 "contig_87" 80446920.0, \
 "*contig_13" 80485295.0, \
 "*contig_39" 81292077.0, \
 "*contig_104" 83672953.0, \
 "*contig_115" 83717608.0, \
 "contig_23" 83800586.0, \
 "contig_51" 84019775.0, \
 "contig_102" 85053968.0, \
 "contig_19" 85373685.0, \
 "*contig_12" 87093928.0, \
 "*contig_31" 99336814.0, \
 "contig_32" 100267349.0, \
 "contig_70" 102970776.0, \
 "*contig_100" 103009753.0, \
 "contig_50" 103308282.0, \
 "contig_29" 103372001.0, \
 "*contig_34" 104057369.0, \
 "contig_62" 104218196.0, \
 "contig_33" 104436588.0, \
 "*contig_15" 104835794.0, \
 "*contig_16" 105780091.0, \
 "contig_4" 111678779.0, \
 "*contig_114" 119265598.0, \
 "contig_52" 119525536.0, \
 "contig_60" 119560646.0, \
 "contig_59" 119744775.0, \
 "contig_83" 119765056.0, \
 "contig_80" 119781510.0, \
 "contig_93" 119815131.0, \
 "contig_68" 119819322.0, \
 "contig_10" 119876106.0, \
 "contig_75" 119951026.0, \
 "contig_96" 120069388.0, \
 "contig_92" 120185916.0, \
 "contig_84" 120207081.0, \
 "contig_35" 120237605.0, \
 "contig_66" 120280611.0, \
 "contig_44" 120378746.0, \
 "contig_111" 120421436.0, \
 "contig_97" 120465564.0, \
 "contig_65" 120478669.0, \
 "contig_71" 120512093.0, \
 "" 120515690 \
)
set size 1,1
set grid
unset key
set border 0
set tics scale 0
set xlabel "REF"
set ylabel "QRY"
set format "%.0f"
set mouse format "%.0f"
set mouse mouseformat "[%.0f, %.0f]"
set xrange [1:119667750]
set yrange [1:120515690]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/data/users/sschaerer/assembly_annotation_course/mummer_output/flye_vs_ref.fplot" title "FWD" w lp ls 1, \
 "/data/users/sschaerer/assembly_annotation_course/mummer_output/flye_vs_ref.rplot" title "REV" w lp ls 2
