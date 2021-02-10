setwd('E:/cibersort_0104/2.DEG')
dir.create('limma') # output directory

library(GEOquery)
library(limma)
library(dplyr)



# prep exp data
f <- read.csv('TCGA_expression.txt',sep='\t')
dim(f)
View(head(f))
f <- f[-1,]
rownames(f) <- f[,1]
f <- f[,-1]
f <- f[,order(colnames(f))]
View(f[1:5,1:5])

# prep clinical data

clin <- read.csv('../1.clustering/clustered_sample.txt',sep='\t')
View(clin)
clin <- clin[,order(colnames(clin))]
length(colnames(clin))

# trim exp data
f <- f[,colnames(clin)]
dim(f)
f <- as.data.frame(f)
sprr3 <- f['SPRR3|6707']

f <- t(f)

clin <- as.data.frame(t(clin))

f[1:5,1:5]


# change value Hier_k3 == 2 into 0 (merge 0,2) : 0 : high risk, 1 : low risk

View(clin)
clin$Hier_k3[clin$Hier_k3==2] <- 0
clin$Hier_k3 <- replace(clin$Hier_k3,grepl(0,clin$Hier_k3),'high_risk')
clin$Hier_k3 <- replace(clin$Hier_k3,grepl(1,clin$Hier_k3),'low_risk')
View(clin)
clin$days <- round((clin$days)*30,0)

#check dimension
dim(clin)
dim(f)

group_H <- clin$Hier_k3
design <- model.matrix(~0+group_H)
colnames(design)
colnames(design) <- c('High_risk','Low_risk')

df1 <- as.data.frame(t(f[1:5,1:5]))

f <- as.data.frame(t(f))
rownames(f)
f[] <- lapply(f, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})


#sprr3

sprr3_h3=cbind(sprr3,clin$Hier_k3)
sprr3_h3$`SPRR3|6707` <- log2(sprr3_h3$`SPRR3|6707`)
mean(sprr3_h3$`SPRR3|6707`[sprr3_h3['clin$Hier_k3']=='low_risk'])
mean(sprr3_h3$`SPRR3|6707`[sprr3_h3['clin$Hier_k3']=='high_risk'])

# limma analysis

fit = lmFit(log2(f),design) # essential for RNA-seq data
cont <- makeContrasts(diff=Low_risk-High_risk,levels=design) ### low risk focused!!!!!
fit.cont <- contrasts.fit(fit,cont)
fit.cont <- eBayes(fit.cont)
res <- topTable(fit.cont,number=Inf)


res <- na.omit(res)
res <- res[!is.infinite(rowSums(res)),]

View(res)
write.table(res,file='limma/Low_vs_High_risk.txt',sep='\t',quote = FALSE)

topT <- as.data.frame(res)
View(topT)
colnames(topT)
# Adjusted P values

with(topT, plot(logFC, -log10(adj.P.Val), pch=20, main="Volcano plot", col='grey', cex=1.0, xlab=bquote(~Log[2]~fold~change), ylab=bquote(~-log[10]~Q~value)))

cut_pvalue <- 0.001
cut_lfc <- 1
with(subset(topT, adj.P.Val<cut_pvalue & logFC>cut_lfc), points(logFC, -log10(adj.P.Val), pch=20, col='red', cex=1.5))
with(subset(topT, adj.P.Val<cut_pvalue & logFC<(-cut_lfc)), points(logFC, -log10(adj.P.Val), pch=20, col='blue', cex=1.5))

## Add lines for FC and P-value cut-off
abline(v=0, col='black', lty=3, lwd=1.0)
abline(v=-cut_lfc, col='black', lty=4, lwd=2.0)
abline(v=cut_lfc, col='black', lty=4, lwd=2.0)
abline(h=-log10(max(topT$adj.P.Val[topT$adj.P.Val<cut_pvalue], na.rm=TRUE)), col='black', lty=4, lwd=2.0)
