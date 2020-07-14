source("compute_cis.R")
require(ggplot2)

make_systems_plot <- function(dataset, model) {
    system_subset <- c("Champion", "Chal. 1", "Chal. 2", "Chal. 3", "Chal. 4")
    system_cis <- compute_system_cis(model, system_subset) 

    # Reorder presentation
    system_cis$names_f <- factor(system_cis$names, levels=c("Chal. 4", 
                                                            "Chal. 3", 
                                                            "Chal. 2", 
                                                            "Chal. 1", 
                                                            "Champion"))

    p <- ggplot(system_cis)
    p <- p + geom_vline(aes(xintercept=0), color="#7570b3")
    p <- p + geom_errorbarh(aes(xmin=`2.5%`, xmax=`97.5%`, y=`names_f`, 
                                color=`names_f`))
    p <- p + geom_point(aes(x=`mean`, y=`names_f`), size=1.5, shape=21, 
                        color="black", fill="#4daf4a")

    syscolors <- c("Champion" = "#1f78b4", "Chal. 1" = "#a6cee3", 
                   "Chal. 2" = "#b2df8a", "Chal. 3" = "#33a02c",
                   "Chal. 4" = "#fb9a99")

    p <- p + scale_color_manual(values = syscolors)
    p <- p + coord_cartesian()
    p <- p + theme(legend.position="none")

    p <- p + theme(panel.spacing=unit(1, "lines"))
    p <- p + xlab("Estimate")
    p <- p + ylab("System")
    p <- p + theme(legend.background = element_blank(), 
                   legend.key=element_blank())

    ggsave(p, filename=paste0("../output/", dataset, "_systems.pdf"), width=4, 
           height=3, device=cairo_pdf)
}

make_topics_plot <- function(dataset, model) {
    topic_cis <- compute_topic_cis(model) 

    # Reorder presentation
    p <- ggplot(topic_cis, aes(x=reorder(names, -mean)))

    p <- p + geom_hline(aes(yintercept=0), color="#7570b3")
    p <- p + geom_errorbar(aes(ymin=`2.5%`, ymax=`97.5%`), size=0.2, 
                           color="#a6d854")
    p <- p + geom_point(aes(y=`mean`), size=1.0, shape=24, 
                        color="black", fill="#4daf4a")
    p <- p + coord_cartesian()
    p <- p + theme(legend.position="none")

    p <- p + theme(panel.spacing=unit(1, "lines"))
    p <- p + xlab("Topics")
    p <- p + ylab("Estimate")
    p <- p + theme(legend.background = element_blank(), 
                   legend.key=element_blank())
    p <- p + theme(axis.text.x = element_blank(),
                     axis.title.y= element_text(margin = margin(r = 25.5)),
                     axis.ticks.x = element_blank())
    p <- p + theme(axis.text.x = element_text(angle = 60, size=4, hjust=1)) 

    ggsave(p, filename=paste0("../output/", dataset, "_topics.pdf"), width=4, 
           height=3, device=cairo_pdf)
}

# Generate graphs for each corpus
for (dataset in c("rb04", "trec17", "trec18")) {
    model <- compute_bayesian_model(paste0("../data/", dataset, "_data.csv"), 
                                    TRUE)
    make_systems_plot(dataset, model)
    make_topics_plot(dataset, model)
}
