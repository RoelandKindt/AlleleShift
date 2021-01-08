population.shift <- function(
  baseline.env.data, future.env.data, option=c("PCA", "RDA"),
  vector.multiply=1
)
{

  message("Checking data sets with BiodiversityR::check.datasets")  
BiodiversityR::check.datasets(baseline.env.data, future.env.data)  
  
pca.input <- rbind(baseline.env.data, future.env.data)

np <- nrow(baseline.env.data)

pca.env <- data.frame(climate=factor(c(rep("baseline", np), 
                                       rep("future", np))))

if (option == "PCA") {

message("Fitting PCA with vegan::rda and no explanatory variables")
pca.result <- vegan::rda(pca.input, scale=TRUE)
summary(pca.result)

axis.long1 <- BiodiversityR::axis.long(pca.result, choices=c(1, 2))

plot1 <- vegan::ordiplot(pca.result)

}

if (option == "RDA") {

# scaling important as variables now used as response, not important with those variables as explanatory
message("Fitting RDA with vegan::rda and time period (baseline / future) as explanatory variable")
rda.result <- vegan::rda(pca.input ~ climate, data=pca.env, scale=TRUE)
summary(rda.result)

axis.long1 <- BiodiversityR::axis.long(rda.result, choices=c(1, 2))

plot1 <- vegan::ordiplot(rda.result)  

}


species.long1 <- BiodiversityR::species.long(plot1)

pca.env <- cbind(pca.input, pca.env)

sites.long1 <- BiodiversityR::sites.long(plot1, env.data=pca.env)

segment.long1 <- sites.long1[sites.long1$climate == "baseline", c("labels", "axis1", "axis2")]
segment.long2 <- sites.long1[sites.long1$climate == "future", c("labels", "axis1", "axis2")]
segment.long3 <- data.frame(cbind(segment.long1, segment.long2))  

  BioR.theme <- ggplot2::theme(
        panel.background = ggplot2::element_blank(),
        panel.border = ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank(),
        axis.line = ggplot2::element_line("gray25"),
        text = ggplot2::element_text(size = 12),
        axis.text = ggplot2::element_text(size = 10, colour = "gray25"),
        axis.title = ggplot2::element_text(size = 10, colour = "gray25"),
        legend.title = ggplot2::element_text(size = 10),
        legend.text = ggplot2::element_text(size = 10),
        legend.key = ggplot2::element_blank())

  
plotggx <- ggplot2::ggplot() + 
    ggplot2::geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
    ggplot2::geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
    ggplot2::xlab(axis.long1[1, "label"]) +
    ggplot2::ylab(axis.long1[2, "label"]) +  
    ggplot2::scale_x_continuous(sec.axis = ggplot2::dup_axis(labels=NULL, name=NULL)) +
    ggplot2::scale_y_continuous(sec.axis = ggplot2::dup_axis(labels=NULL, name=NULL)) +
    ggforce::geom_mark_ellipse(data=sites.long1, 
                   ggplot2::aes(x=sites.long1$axis1, y=sites.long1$axis2, colour=sites.long1$climate), 
                   fill=ggplot2::alpha("grey50", 0.3), expand=0, size=0.2, show.legend=FALSE) +
    ggplot2::geom_point(data=sites.long1, 
               ggplot2::aes(x=sites.long1$axis1, y=sites.long1$axis2, colour=sites.long1$climate, shape=sites.long1$climate), 
               alpha=0.7, size=5) +
    ggplot2::geom_segment(data=species.long1, 
                 ggplot2::aes(x=0, y=0, xend=species.long1$axis1*vector.multiply, yend=species.long1$axis2*vector.multiply), 
                 colour="black", size=0.7, arrow=ggplot2::arrow()) +
    ggplot2::geom_segment(data=segment.long3, 
                 ggplot2::aes(x=segment.long3$axis1, y=segment.long3$axis2, xend=segment.long3$axis1.1, yend=segment.long3$axis2.1), 
                 colour="darkolivegreen4", size=0.7, arrow=ggplot2::arrow()) +
    ggplot2::geom_label(data=species.long1, 
                    ggplot2::aes(x=species.long1$axis1*vector.multiply, y=species.long1$axis2*vector.multiply, label=species.long1$labels),
                    colour="black", fill="grey90", alpha=0.4, fontface="bold", show.legend=FALSE) +
    ggplot2::geom_label(data=subset(sites.long1, sites.long1$climate=="baseline"), 
                    ggplot2::aes(x=subset(sites.long1, sites.long1$climate=="baseline")$axis1, 
                    	y=subset(sites.long1, sites.long1$climate=="baseline")$axis2, 
                    	label=subset(sites.long1, sites.long1$climate=="baseline")$labels, 
                    	colour=subset(sites.long1, sites.long1$climate=="baseline")$climate),
                    alpha=0.7, size=3, nudge_y=0.1, show.legend=FALSE) +
    BioR.theme +
    ggplot2::scale_colour_manual(values=rev(ggsci::pal_npg()(2))) +
    ggplot2::labs(shape="Climate", colour="Climate", fill="Climate") +
    ggplot2::coord_fixed(ratio=1)

return(plotggx)
}
