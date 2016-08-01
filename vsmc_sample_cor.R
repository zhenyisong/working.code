library(gplots)
library(xlsx)
library(Rsubread)
library(edgeR)
library(limma)
library(org.Mm.eg.db)
library(DESeq2)
library(gplots)
library(genefilter)
library(RColorBrewer)

# @parent program
#    mergeAffy.pl
#    mergeRNA

setwd('/home/zhenyisong/data/wanglilab/vsmc_db');

"
these are processed high-through-put data, those 
data needed the Perl script to extract the 
information. the data were inputed by read.table method

RNA-seq data is imported from the Perl script mergeRNAseq.pl
Affy data is imported from Perl script mergeAffy.pl
"
rna.seq.filename = 'final_rna_seq.cos';
non.db.filename  = 'final_nons.cos';
affy.db.filename = 'final_affy.cos';
rna.seq.db = read.table( rna.seq.filename, header = TRUE, sep = "\t",
                         row.names = 1)
non.db     = read.table( non.db.filename , header = TRUE, sep = "\t",
                         row.names = 1)
affy.db    = read.table( affy.db.filename , header = TRUE, sep = "\t",
                         row.names = 1)
"
transform the data to the data.frame
"
rna.matrix     = as.matrix(rna.seq.db)

wangli.data    = apply(rna.matrix[,c('SRR01','SRR02')], 1, median) - apply(rna.matrix[,c('SRR03','SRR04')], 1, median)
	
GSE35664_1     = rna.matrix[,'SRR407420'] - rna.matrix[,'SRR407419']
GSE35664_2     = rna.matrix[,'SRR407421'] - rna.matrix[,'SRR407419']
GSE35664_3     = rna.matrix[,'SRR407422'] - rna.matrix[,'SRR407419']

GSE38056       = rna.matrix[,'SRR498452'] - rna.matrix[,'SRR498451']
GSE44461       = apply(rna.matrix[,c('SRR748305','SRR748306','SRR748307')], 1, median) - 
                 apply(rna.matrix[,c('SRR748302','SRR748303','SRR748304')], 1, median)
GSE51878_1     = apply(rna.matrix[,c('SRR1020592','SRR1020593','SRR1020594')], 1, median) - 
                 apply(rna.matrix[,c('SRR1020595','SRR1020596','SRR1020597')], 1, median)
GSE51878_2     = apply(rna.matrix[,c('SRR1020598','SRR1020598','SRR1020600')], 1, median) - 
                 apply(rna.matrix[,c('SRR1020595','SRR1020596','SRR1020597')], 1, median)
GSE60642_1     = apply(rna.matrix[,c('SRR1555818','SRR1555819')], 1, median) - 
                 apply(rna.matrix[,c('SRR1555820','SRR1555821')], 1, median)
GSE60642_2     = apply(rna.matrix[,c('SRR1555816','SRR1555817')], 1, median) - 
                 apply(rna.matrix[,c('SRR1555820','SRR1555821')], 1, median)

GSE60641       = apply(rna.matrix[,c('SRR1556006','SRR1556007','SRR1556008')], 1, median) - 
                 apply(rna.matrix[,c('SRR1556003','SRR1556004','SRR1556005')], 1, median)

GSE65354_1     = rna.matrix[,'SRR1776527'] - rna.matrix[,'SRR1776529']
GSE65354_2     = rna.matrix[,'SRR1776526'] - rna.matrix[,'SRR1776528']

pseudo_row     = seq(1:length(wangli.data))
rna.kd.matrix  = c()
rna.kd.matrix  = rbind(pseudo_row,wangli.data,GSE35664_1,GSE35664_2,GSE35664_3)
rna.kd.matrix  = rbind(rna.kd.matrix, GSE38056,GSE44461,GSE51878_1,GSE51878_2 )
rna.kd.matrix  = rbind(rna.kd.matrix, GSE60642_1,GSE60642_2, GSE60641, GSE65354_1,GSE65354_2)
rna.kd.matrix  = rna.kd.matrix[-1,]
rna.kd.matrix  = t(rna.kd.matrix)

colnames(rna.kd.matrix) = c('VSMC.wang','AngII-1h','AngII-3h','AngII-24h','AngII','TCF21',
                             'SENCR_kd','SENCR_mk','Jag_kn','Jag_hr','JAG','Hsp60','TNFA-a')

"
transform the data.frame into the log format
this step is deprecated
the raw RNA-seq data have been already processed
by rlog fucntion, stablize the variance
"
#rna.log.matrix = log(rna.matrix + 1)
affy.matrix    = as.matrix(affy.db)
#colnames(affy.matrix)

GSE29955_1     = apply(affy.matrix[,c(4:6)], 1, median) - 
                 apply(affy.matrix[,c(1:3)], 1, median)
GSE29955_2     = apply(affy.matrix[,c(10:12)], 1, median) - 
                 apply(affy.matrix[,c(7:9)], 1, median)
GSE29955_3     = apply(affy.matrix[,c(16:18)], 1, median) - 
                 apply(affy.matrix[,c(13:15)], 1, median)
GSE36487_1     = affy.matrix[,20] - affy.matrix[,19]
GSE36487_2     = affy.matrix[,21] - affy.matrix[,19]
GSE12261_1     = apply(affy.matrix[,c(25:27)], 1, median) - 
                 apply(affy.matrix[,c(22:24)], 1, median)
GSE12261_2     = apply(affy.matrix[,c(31:33)], 1, median) - 
                 apply(affy.matrix[,c(28:30)], 1, median)
GSE17543       = affy.matrix[,35] - affy.matrix[,34]
GSE13791_1     = apply(affy.matrix[,c(54,55)], 1, median) - 
                 apply(affy.matrix[,c(52,53)], 1, median)
GSE13791_2     = apply(affy.matrix[,c(59:61)], 1, median) - 
                 apply(affy.matrix[,c(56,58)], 1, median)
GSE11367       = apply(affy.matrix[,c(63,65,67)], 1, median) - 
                 apply(affy.matrix[,c(62,64,66)], 1, median)
GSE47744_1     = apply(affy.matrix[,c(70,71)], 1, median) - 
                 apply(affy.matrix[,c(68,69)], 1, median)
GSE47744_2     = apply(affy.matrix[,c(74,75)], 1, median) - 
                 apply(affy.matrix[,c(72,73)], 1, median)
GSE47744_3     = apply(affy.matrix[,c(76,77)], 1, median) - 
                 apply(affy.matrix[,c(72,73)], 1, median)
GSE42813_1     = apply(affy.matrix[,c(78,79)], 1, median) - 
                 apply(affy.matrix[,c(80,81)], 1, median)
GSE42813_2     = apply(affy.matrix[,c(80,81)], 1, median) - 
                 apply(affy.matrix[,c(82,83)], 1, median)
GSE60447_1     = apply(affy.matrix[,c(84,85)], 1, median) - 
                 apply(affy.matrix[,c(86:88)], 1, median)
GSE60447_2     = apply(affy.matrix[,c(82,94)], 1, median) - 
                 apply(affy.matrix[,c(89:91)], 1, median)

GSE19441       = apply(affy.matrix[,c(96,98,100)], 1, median) - 
                 apply(affy.matrix[,c(95,97,99)], 1, median)
GSE56819_1     = apply(affy.matrix[,c(104:106)], 1, median) - 
                 apply(affy.matrix[,c(101:103)], 1, median)
GSE56819_2     = apply(affy.matrix[,c(107:109)], 1, median) - 
                 apply(affy.matrix[,c(101:103)], 1, median)

GSE30004       = apply(affy.matrix[,c(110:121)], 1, median) - 
                 apply(affy.matrix[,c(122:133)], 1, median)

GSE17556_1     = apply(affy.matrix[,c(137:139)], 1, median) - 
                 apply(affy.matrix[,c(134:136)], 1, median)
GSE17556_2     = apply(affy.matrix[,c(140:142)], 1, median) - 
                 apply(affy.matrix[,c(134:136)], 1, median)
GSE17556_3     = apply(affy.matrix[,c(146:148)], 1, median) - 
                 apply(affy.matrix[,c(143:145)], 1, median)
GSE17556_4     = apply(affy.matrix[,c(149:151)], 1, median) - 
                 apply(affy.matrix[,c(146:148)], 1, median)
GSE63425_1     = apply(affy.matrix[,c(152,153,159,163)], 1, median) - 
                 apply(affy.matrix[,c(154,155,158,162)], 1, median)
GSE63425_2     = apply(affy.matrix[,c(156,157,160,161)], 1, median) - 
                 apply(affy.matrix[,c(154,155,158,162)], 1, median)

GSE68021_1     = apply(affy.matrix[,c(167:169)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE68021_2     = apply(affy.matrix[,c(170:172)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE68021_3     = apply(affy.matrix[,c(173:175)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE68021_4     = apply(affy.matrix[,c(176:178)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE68021_5     = apply(affy.matrix[,c(179:181)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE68021_6     = apply(affy.matrix[,c(182:184)], 1, median) - 
                 apply(affy.matrix[,c(164:166)], 1, median)
GSE50251       = apply(affy.matrix[,c(185:187)], 1, median) - 
                 apply(affy.matrix[,c(188:190)], 1, median)
GSE66538       = apply(affy.matrix[,c(195:198)], 1, median) - 
                 apply(affy.matrix[,c(191:194)], 1, median)
GSE66280       = apply(affy.matrix[,c(205:210)], 1, median) - 
                 apply(affy.matrix[,c(199:204)], 1, median)
GSE15713       = affy.matrix[,212] - affy.matrix[,211]
GSE66624       = apply(affy.matrix[,c(219:224)], 1, median) - 
                 apply(affy.matrix[,c(213:218)], 1, median)
GSE13594       = apply(affy.matrix[,c(227,228)], 1, median) - 
                 apply(affy.matrix[,c(225,226)], 1, median)
GSE19106       = apply(affy.matrix[,c(231,232)], 1, median) - 
                 apply(affy.matrix[,c(229,230)], 1, median)
GSE21573_1     = apply(affy.matrix[,c(235,236)], 1, median) - 
                 apply(affy.matrix[,c(233,234)], 1, median)
GSE21573_2     = apply(affy.matrix[,c(237,238)], 1, median) - 
                 apply(affy.matrix[,c(233,234)], 1, median)
GSE21573_3     = apply(affy.matrix[,c(239,240)], 1, median) - 
                 apply(affy.matrix[,c(233,234)], 1, median)
GSE21573_4     = apply(affy.matrix[,c(241,242)], 1, median) - 
                 apply(affy.matrix[,c(233,234)], 1, median)
GSE31080_1     = affy.matrix[,244] - affy.matrix[,243]
GSE31080_2     = affy.matrix[,246] - affy.matrix[,245]
GSE15841_1     = apply(affy.matrix[,c(253,254)], 1, median) - 
                 apply(affy.matrix[,c(247,248)], 1, median)
GSE15841_2     = apply(affy.matrix[,c(255,256)], 1, median) - 
                 apply(affy.matrix[,c(249,250)], 1, median)
GSE15841_3     = apply(affy.matrix[,c(257,258)], 1, median) - 
                 apply(affy.matrix[,c(251,252)], 1, median)
GSE19909       = apply(affy.matrix[,c(259,261)], 1, median) - 
                 apply(affy.matrix[,c(262,264)], 1, median)
GSE21403       = apply(affy.matrix[,c(267,268)], 1, median) - 
                 apply(affy.matrix[,c(265,266)], 1, median)  


pseudo_row     = seq(1:length(GSE21403))
affy.kd.matrix = c()
affy.kd.matrix = rbind(pseudo_row, GSE29955_1,GSE29955_2,GSE29955_3)
affy.kd.matrix = rbind(affy.kd.matrix, GSE36487_1,GSE36487_2,GSE12261_1,GSE12261_2)
affy.kd.matrix = rbind(affy.kd.matrix, GSE17543,GSE13791_1,GSE13791_2,GSE11367)
affy.kd.matrix = rbind(affy.kd.matrix, GSE47744_1,GSE47744_2,GSE47744_3,GSE42813_1,GSE42813_2)
affy.kd.matrix = rbind(affy.kd.matrix, GSE60447_1,GSE60447_2,GSE19441,GSE56819_1,GSE56819_2)
affy.kd.matrix = rbind(affy.kd.matrix, GSE30004,GSE17556_1,GSE17556_2,GSE17556_3,GSE17556_4)
affy.kd.matrix = rbind(affy.kd.matrix, GSE63425_1,GSE63425_2,GSE68021_1,GSE68021_2,GSE68021_3)
affy.kd.matrix = rbind(affy.kd.matrix, GSE68021_4,GSE68021_5,GSE68021_6,GSE50251,GSE66538,GSE66280)
affy.kd.matrix = rbind(affy.kd.matrix, GSE15713,GSE66624,GSE13594,GSE19106)
affy.kd.matrix = rbind(affy.kd.matrix, GSE21573_1,GSE21573_2,GSE21573_3,GSE21573_4)
affy.kd.matrix = rbind(affy.kd.matrix, GSE31080_1,GSE31080_2,GSE15841_1,GSE15841_2,GSE15841_3,GSE19909,GSE21403)


affy.kd.matrix  = affy.kd.matrix[-1,]
affy.kd.matrix  = t(affy.kd.matrix)

colnames(affy.kd.matrix) = c('OPG',   'RANKL',        'TRAIL',      'moxLDL_3h','moxLDL_21h','ME-treated_4h','ME-treated_30h',
                            'FoxM1', 'T.cruzi_24h', 'T.cruzi_48','IL-17','Cholesterol.1','Cholesterol.1_II','HDL',
                            'APOE+VE', 'APOE','Zyxin','Zyxin_Stretch','CASMC', 'ROCK1', 'ZIPT','TGF-B_Rx','HG_TSP',
                            'HG1-LG1','Man+TSP1','Man','TAB+GCA','TAB-GCA','LDL_1h','LDL_5h','LDL_24h','oLDL_1h','oLDL_5h',
                            'oLDL_24h', 'embryonic origin-specific','jasplakinolide','Glucose','Glut1','Versican',
                             'CD9','PDGF-BB','BMPR2','cdBMPR2','knBMPR2','edBMPR2','IL-1b','PDGF-DD','thrombin','TRAP',
                             'TRAP+PTX','fluid Stress','IL-1b')

"    
the following module is to extract the differential expression
gene name from VSMC data analysis.
see the whole script rsubread_limma.R
get the gene names from DEG analysis
"


"
this is the targets file which indicate the fastq file path and other experiment
inforamtion regarding the sequence
"
targets.file      = '/home/zhenyisong/data/wanglilab/projects/2016-05-26/targets.txt'
reads.files       = read.table(targets.file,header = F)

"
output path, where the resuls are saved
"
reads.path        = '/home/zhenyisong/data/wanglilab/projects/2016-05-26/'
output.path       = '/home/zhenyisong/data/wanglilab/projects/2016-05-26/results/'


"
generate the path vectors
"
reads.paths       = paste0(reads.path,reads.files$V1)
outputs.files     = paste0(output.path,reads.files$V1,'.sam')


# get gene's counts
gene = featureCounts( outputs.files, useMetaFeatures = TRUE, 
                      annot.inbuilt = "mm10", allowMultiOverlap = TRUE)

gene.counts  = gene$counts
gene.ids     = gene$annotation$GeneID
colnames(gene.counts) = c( 'VSMC_H2AZ44_Day_4_1','VSMC_H2AZ44_Day_4_2',
                           'VSMC_NT_Day_4_1','VSMC_NT_Day_4_1');


keytypes(org.Mm.eg.db)

columns  = c("ENTREZID","SYMBOL", "MGI", "GENENAME");
GeneInfo = select( org.Mm.eg.db, keys= as.character(gene.ids), 
                   keytype="ENTREZID", columns = columns);
m        = match(gene$annotation$GeneID, GeneInfo$ENTREZID);
Ann      = cbind( gene$annotation[, c("GeneID", "Chr","Length")],
                          GeneInfo[m, c("SYMBOL", "MGI", "GENENAME")]);

rownames(gene.counts) = GeneInfo[m,'SYMBOL'];
write.table( gene.counts, file = "vsmc.counts.txt", quote = FALSE, 
             sep = "\t", row.names = TRUE, col.names = TRUE);

Ann$Chr  =  unlist( lapply(strsplit(Ann$Chr, ";"), 
                    function(x) paste(unique(x), collapse = "|")))
Ann$Chr  = gsub("chr", "", Ann$Chr)

gene.exprs = DGEList(counts = gene.counts, genes = Ann)
A          = rowSums(gene.exprs$counts)
isexpr     = A > 50

hasannot   = rowSums(is.na(gene.exprs$genes)) == 0
gene.exprs = gene.exprs[isexpr & hasannot, , keep.lib.size = FALSE]
gene.exprs = calcNormFactors(gene.exprs)

d          = gene.exprs

group  = factor(c('CT','CT','TR','TR'));
design = model.matrix(~ 0 + group);
colnames(design) = c('Control','Treatment')
contrast.matrix  = makeContrasts(Treatment - Control, levels = design)
d.norm          = voom(d, design = design)
fit             = lmFit(d.norm, design)
fit2            = contrasts.fit(fit,contrast.matrix)
fit2            = eBayes(fit2)


#gene.result = topTable( fit2, coef = ncol(design), 
#                        number = Inf, adjust.method="BH", sort.by="p");
gene.result = topTable( fit2, number  = Inf, 
                        adjust.method = "BH", 
                        sort.by = "p",
                        lfc     = 0.58,
                        p.value = 0.05);
"
get the DEG gene names and transform the 
gene name to upper case.
"
deg.names   = rownames(gene.result)
deg.names   = toupper(deg.names)
#
# -- module end
#

"
get the common name
and gene expression matrix
"
common.name          = intersect(rownames(rna.kd.matrix), rownames(affy.kd.matrix))
common.name          = intersect(common.name, deg.names)
colnames.vector      = c(colnames(rna.kd.matrix),colnames(affy.kd.matrix))
common.matrix        = seq(1:length(colnames.vector))

for( gene in common.name) {
    gene.exprs    = matrix( c( rna.kd.matrix[gene,],
                               affy.kd.matrix[gene,]),
                            byrow = F, nrow = 1)
    common.matrix = rbind(common.matrix,gene.exprs)
}
length(common.name)
exprs.matrix            = common.matrix[-1,]
colnames(exprs.matrix)  = colnames.vector

results = cor(exprs.matrix,method = 'spearman')

#rna.cor = cor(rna.log.matrix, method = 'spearman')


#----------------------------------------------
# random shuffle the matrix and generate
# the Spearman p.value distribution
# simulation begin
#----------------------------------------------
m_len      = dim(exprs.matrix)[2]
pseudo_num = seq(m_len *m_len)
random.matrix = exprs.matrix
shuffle.times = 100000
for( j in 1:shuffle.times) {
    for ( i in 1:dim(exprs.matrix)[1]) {
        random.matrix[1,] = exprs.matrix[1,sample(dim(exprs.matrix)[2])]
    }
    pseudo.cor = cor(random.matrix, method = 'spearman')
    pseudo_num = cbind(pseudo_num,as.vector(pseudo.cor))
}
pseudo_num = pseudo_num[,-1]

pdf("pseudo.pvalue.pdf")
hist(as.vector(pseudo_num))
dev.off()
cutoff   = mean(as.vector(pseudo_num) > 0.2)
fileConn = file("cutoff.txt")
writeLines(c("hello","world",cutoff), fileConn)
close(fileConn)

setwd('/home/zhenyisong/data/wanglilab/vsmc_db');
save.image(file = 'vsmc.Rdata')
quit("no")

# ---simulation end

#-------------------------------------------------------------
# Figure
# heatmap of sample correlation
#-------------------------------------------------------------

my_palette     = rev(colorRampPalette(brewer.pal(10, "RdBu"))(256))
heatmap.result = heatmap.2(results, col = my_palette, scale  = 'none', 
						   Rowv = FALSE,Colv = FALSE, density.info = 'none',
                           key  = TRUE, trace='none', symm = T,symkey = F,symbreaks = T,
						   margins = c(4,4),dendrogram = 'none',
                           cexRow  = 0.3, cexCol = 0.3,
                           labRow = rownames(results),
                           labCol = colnames(results)
						  );
#my_palette  = colorRampPalette(c("white","green","green4","violet","purple"))(255)

#whole.heatmap = heatmap( results,  margins = c(10, 10),
#                         cexCol = 0.4, cexRow = 0.4);
#partial.map = results[results['wangli.data',] > 0.9,results['wangli.data',] > 0.9]

partial.matrix = results[ results['VSMC.wang',] > 0.2 | results['VSMC.wang',] < -0.2, 
                       results[,'VSMC.wang'] > 0.2 | results[,'VSMC.wang'] < -0.2]
partial.map    = signif(partial.matrix, digits = 3)
#write.xlsx(partial.map, file = "cutoff_0.8.xls")
#heatmap(  partial.map,  margins = c(10, 10),
#           symm = TRUE, 
#           cexCol = 1, cexRow = 1);

#partial.distance = 1 - partial.map
heatmap.result = heatmap.2(partial.map, col = my_palette, scale  = 'none', 
						   Rowv = FALSE,Colv = FALSE, density.info = 'none',
                           key  = TRUE, trace='none', symm = T,symkey = F,symbreaks = T,
						   cexRow  = 0.8, cexCol = 0.8,srtCol = 30, cellnote = partial.map,
                           notecex = 0.8, notecol= "red",
						   margins = c(12,6),dendrogram = 'none',
                           labRow = rownames(partial.map),
                           labCol = colnames(partial.map)
						  );

#rownames(results)[results['SRR01',] > 0.9]
#colnames.vector[whole.heatmap$rowInd]
#summary(as.vector(rna.cor))
spearman.d = as.vector(results)
hist(spearman.d, prob = TRUE, n = 200, col = 'grey')
lines(density(spearman.d), col = "blue", lwd = 2) # add a density estimate with defaults
lines(density(spearman.d, adjust=2), lty = "dotted", col = "darkgreen", lwd = 2) 


#-------------------------------------------------------------
# Figure
# heatmap of smooth muscle differentiation markers
#-------------------------------------------------------------

vcms.markers  = 'SM-markers.xlsx' # this data is manually curated
vcms.table    = read.xlsx(vcms.markers,header = TRUE, stringsAsFactors = FALSE, 1)
vsmc.genename = vcms.table$GeneSymbol

dge.tmm                  = t(t(gene.exprs$counts) * gene.exprs$samples$norm.factors)
#dge.tmm.counts <- round(dge.tmm, digits = 0)
dge.tmm.counts           = apply(dge.tmm,2, as.integer)
rownames(dge.tmm.counts) = gene.exprs$genes$SYMBOL

sample.info              = data.frame( treat  = c('TR','TR','CT','CT') )
dds                      = DESeqDataSetFromMatrix( countData = dge.tmm.counts,
                                                   colData   = sample.info,
                                                   design    = ~ treat)
vsd                      = varianceStabilizingTransformation(dds, blind = FALSE);
vsd.expr                 = assay(vsd)
colnames(vsd.expr)       = c('VSMC_H2AZ44_1','VSMC_H2AZ44_2','VSMC_NT_1','VSMC_NT_2')
vsd.markers              = vsd.expr[vsmc.genename,]

# this code is extracted from 
# http://stackoverflow.com/questions/17820143/how-to-change-heatmap-2-color-range-in-r
# http://seqanswers.com/forums/archive/index.php/t-12022.html

#colors      = c(seq(-3,-2,length=100),seq(-2,0.5,length=100),seq(0.5,6,length=100))
#my_palette  = colorRampPalette(c("red", "black", "green"))(n = 299)
#my_palette  = colorRampPalette(c("white","green","green4","violet","purple"))(255)
my_palette  = rev(colorRampPalette(brewer.pal(10, "RdBu"))(256))
#my_palette  = colorRampPalette(c("red","white","blue"))(256)
heatmap.result = heatmap.2(vsd.markers, col = my_palette, scale  = 'row', 
						   Rowv = TRUE,Colv = FALSE, density.info = 'none',
                           key  = TRUE, trace='none', symm = F,symkey = F,symbreaks = T,
						   cexRow  = 1.5, cexCol = 1.5,srtCol = 30,
                           distfun = function(d) as.dist(1-cor(t(d),method = 'pearson')),
						   hclustfun  = function(d) hclust(d, method = 'complete'),
						   dendrogram = 'row',margins = c(12,6),labRow = vsmc.genename,
						  );

