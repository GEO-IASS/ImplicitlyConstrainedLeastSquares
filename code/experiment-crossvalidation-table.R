load(paste0("data/crossvalidation-20repeats-enoughlabeled-.Rdata"))


df_res <- 1:length(cvresults) %>% 
  lapply(function(x) {cvresults[[x]]$results %>% melt %>% mutate(Dataset=cvresults[[x]]$dataset_name)}) %>% 
  bind_rows

colnames(df_res) <- c("repeat","Classifier","Measure","Value","Dataset")

## Print results
table.CrossValidation<-function(object,caption="",classifier_names=NULL,measure=1) {
  # overfolds<-apply(object$results,c(1,3:4),mean,na.rm=T)
  if (is.list(object)) {
    if ("results" %in% names(object)) {
      object<-list(object)
    }
  } else {
    stop("Supplied object is not a cross-validation results object")
  }

  if (is.null(classifier_names)) {
    classifier_names<-dimnames(object[[1]]$results)[[2]]
  }

  cat("\\begin{table}\n")
  cat("\\caption{",caption,"} \\label{table:cvresults}\n",sep="")
  cat("\\begin{tabular}{l|",paste(rep("l",dim(object[[1]]$results)[2]),collapse=""),"}\n",sep="")
  
  cat("Dataset &",paste(classifier_names,collapse=" & "),"\\\\ \n")
  cat("\\hline\n")
  sapply(1:length(object), function(n) { 
    cat(object[[n]]$dataset_name,"")
    overfolds<-object[[n]]$results
    means<-apply(overfolds,c(2:3),mean,na.rm=T)
    sds<-apply(overfolds,2:3,sd)
    
    options(digits=2)
  for (c in 1:dim(means)[1]) {
     csd<-sprintf("%.2f",sds[c,measure])
     cm<-sprintf("%.2f",1-means[c,measure])
     numbetter<-sprintf(" (%d)",sum(overfolds[,1,measure]>overfolds[,c,measure]))
     make_bold <- (t.test(overfolds[,1,measure],overfolds[,c,measure])$p.value<0.05)&all(means[c]>=means[1,measure])&(all(c!=c(1,7)))
     make_underlined <- all(means[c,measure]>=means[2:6,measure])&(t.test(overfolds[,c,measure],overfolds[,which.max(means[2:6,measure]),1])$p.value<0.05)&(all(c!=c(1,7)))
     cat("& $",ifelse(make_bold,"\\mathbf{",""),ifelse(make_underlined,"\\underline{",""), cm,numbetter,ifelse(make_underlined,"}",""),ifelse(make_bold,"} $","$"),sep="")
  }
  cat("\\\\ \n")
  })
  cat("\\end{tabular}\n")
  cat("\\end{table}\n")
}
options(digits=2)
table.CrossValidation(cvresults,caption="Average 10-fold cross-validation error and standard deviation over 20 repeats. The classifiers that have been compared are supervised Least Squares (LS), Implicitly constrained least squares (ICLS), the extended ICLS presented in section 4.3 (ICLS$_{ext}$), the adapted ICLS procedure from section 4.2 (ICLS$_{adp}$),  self-learned least squares (SLLS), updated covariance least squares (UCLS, see text) and the supervised least squares classifier that has access to all the labels (LS$_{oracle}$). Indicated in $\\mathbf{bold}$ is whether a semi-supervised classifier significantly outperform the supervised LS classifier, as measured using a $t$-test with a $0.05$ significance level. \\underline{Underlined} indicates whether a semi-supervised classifier is (significantly) best among the three semi-supervised classifiers considered.",classifier_names=c("LS","ICLS","ICLS$_{ext}$","ICLS$_{adp}$","SLLS","UCLS","LS$_{oracle}$"))
