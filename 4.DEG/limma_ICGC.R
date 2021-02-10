setwd('E:/cibersort_0104/2.DEG')
dir.create('limma') # output directory

library(GEOquery)
library(limma)
library(dplyr)



# prep exp data
f <- read.csv('icgc_ORCA_exp_max.txt',sep='\t')
dim(f)
View(head(f))

# prep clinical data

clin <- read.csv('clustered_sample.txt',sep='\t')
View(clin)
rownames(clin) <- clin$Sample_ID
clin <- clin[,order(colnames(clin))]

# trim exp data
f
f <- f[,rownames(clin)]
dim(f)


f[1:5,1:5]

#check dimension
dim(clin)
dim(f)
group_H <- clin$predicted_group

group_H
design <- model.matrix(~0+group_H)
colnames(design)
colnames(design) <- c('High_risk','Low_risk')

df1 <- as.data.frame(t(f[1:5,1:5]))

f <- as.data.frame(t(f))
rownames(f)
f[] <- lapply(f, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})

f <- f+1

# limma analysis

fit = lmFit(t(log2(f)),design) # essential for RNA-seq data
cont <- makeContrasts(diff=Low_risk-High_risk,levels=design)
fit.cont <- contrasts.fit(fit,cont)
fit.cont <- eBayes(fit.cont)
res <- topTable(fit.cont,number=Inf)


res <- na.omit(res)
res <- res[!is.infinite(rowSums(res)),]

View(res)
write.table(res,file='ICGC_Low_vs_High_risk.txt',sep='\t',quote = FALSE)

topT <- as.data.frame(res)
View(topT)
colnames(topT)
# Adjusted P values

with(topT, plot(logFC, -log10(P.Value), pch=20, main="Volcano plot", col='grey', cex=1.0, xlab=bquote(~Log[2]~fold~change), ylab=bquote(~-log[10]~P~value)))

cut_pvalue <- 0.05
cut_lfc <- 1
with(subset(topT, P.Value<cut_pvalue & logFC>cut_lfc), points(logFC, -log10(P.Value), pch=20, col='red', cex=1.5))
with(subset(topT, P.Value<cut_pvalue & logFC<(-cut_lfc)), points(logFC, -log10(P.Value), pch=20, col='blue', cex=1.5))

## Add lines for FC and P-value cut-off
abline(v=0, col='black', lty=3, lwd=1.0)
abline(v=-cut_lfc, col='black', lty=4, lwd=2.0)
abline(v=cut_lfc, col='black', lty=4, lwd=2.0)
abline(h=-log10(max(topT$P.Value[topT$P.Value<cut_pvalue], na.rm=TRUE)), col='black', lty=4, lwd=2.0)

