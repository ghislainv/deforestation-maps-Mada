---
title: "**Cover letter n°3**"
output:
  pdf_document:
    fig_caption: yes
bibliography: biblio.bib
csl: global-change-biology.csl 
colorlinks: yes
link-citations: yes
linkcolor: Blue
citecolor: Blue
urlcolor: Maroon
---

Dr. Ghislain Vieilledent 

CIRAD    
UPR Forêts et Sociétés    
F-34398 Montpellier    
FRANCE

Joint Research Center of the European Commission   
Bio-economy Unit (JRC.D.1)  
I-21027 Ispra (VA)  
ITALY

to

Editors    
_Biological Conservation_ 

Object: Manuscript BIOC_2018_104, answers to reviewers' comments.

####

Dear Editor,

We made our best to improve the quality of the manuscript following Reviewers' comments and we really hope that you will accept our article for publication in your journal.

Best regards,

The authors

# Answers to remarks by Reviewer 1

**Dear authors,**

**In your manuscript "Combining global tree cover loss data with historical national forest cover maps to look at six decades of deforestation and forest fragmentation in Madagascar", you combine two existing forest cover change products (from Harper et al. 2007 and Hansen et al. 2013) to study forest cover change and forest fragmentation on Madagascar between 1953 and 2014. The national product of Harper et al. (2007) provides the earliest estimation of forest cover and is based on the interpretation of aerial photography (1953) and the supervised classification of Landsat satellite images (1973, 1990, 2000). The recent annual estimates of forest cover (2000-2014) are derived from the global product of Hansen et al. (2013) and are also based on a supervised classification of Landsat images. In this study,  the two products were combined using resampling techniques and the gaps in the Harper et al. (2007) 2000 map caused by cloud cover were filled by assigning areas covered by forest in the 2000 map of Hansen et al. (2013) as forest. Similarly, gaps in the Harper et al. (2007) 1990 and 1973 maps were filled by the newly developed gap filled 2000 and 1990 forest cover maps, respectively. Forest cover change was estimated from these newly computed forest cover maps for four ecoregions (moist forest, dry forest, spiny forest and mangrove). In addition, two metrics of forest fragmentation were computed: the density of forest pixels in the neighborhood of a forest pixel (using a moving window) and distance to the forest edge.**

**Your results show a significant decline in natural forest cover on Madagascar, with an initial increase in the deforestation rate (1953 -- 1990), a subsequent decline (1990-2005) and a recent increase of the deforestation rate from 2005 to 2014. The early deforestation estimates were similar to those of Harper et al. (2007), although there were some differences due to the delineation of the ecoregions. The deforestation estimates for recent year (2005-2014) were significantly lower compared to those provided by ONE (2015). However, the trends found in this study are similar to those reported is the previous studies. With deforestation, the fragmentation of the remaining forest increased over the years. Possible limitations are discussed concerning the accuracy of the classification of forest/non-forest, that depend on the accuracy of the used products. Furthermore, you discuss the implications of the observed deforestation for the conservation of species confined to these forests and potential socio-economic drivers of deforestation on Madagascar.**

## General impression

**I have enjoyed reading the manuscript as it is well written and the study presents interesting findings. The ongoing deforestation of Madagascar’s natural forest is certainly a subject worthy of investigation and relevant to policy makers in Madagascar, to NGO’s and scientists studying nature conservation, tropical ecology, land use change, rural development etc. However, I have some concerns about the advances made in this manuscript compared to previous studies and the lack of validation of the forest/non-forest classification. In the manuscript, two existing forest cover products are combined to study forest cover change in an extended period of time. The techniques used to combine the products and to fill cloud cover gaps are well established and there is no validation of the newly developed forest cover maps, not by field measurements (ground truth) and neither by other means (e.g. high resolution aerial photography, above ground biomass maps, lidar data). That the deforestation trend found here corresponds closely to the trend reported in previous studies should therefore be no surprise, as roughly the same data and analysis were used. While the socio-economic drivers of the observed deforestation and the implications for the biodiversity of Madagascar are shortly discussed, additional information about these drivers and implications that would enhance the impact of the manuscript are not presented. Extending the period of forest cover change and analyzing trends in deforestation on Madagascar is a relevant scientific exercise, but without additional validation or secondary data, this manuscript is presently not suited for an international journal in the discipline of conservation biology.**

## Specific comments

**Introduction: Clear and concise, interesting to read**

Thanks for that positive comment.

**Line 38-40: Tropical forests in Madagascar also store a large amount of carbon (Vieilledent et al., 2016) and high rates of deforestation in Madagascar are responsible for large CO2 emissions in the atmosphere (Achard et al.,41 2014). Quantify large, high, etc., also in line 48: “Much lower”**

**Methodology: In the introduction the limitations of the products from Hansen et al. (2013) and Harper et al. (2007) are pointed out (e.g. cloud gaps, the delineation of ecoregions, plantations are classified as forest regrowth) so why would you combine these two products? Why not start over from the beginning using "raw" Landsat data freely available online and use a single supervised classification method and training dataset. This would reduce the uncertainties related to differences between data products in tree cover/forest definitions, training data, map projection, etc.**

**Line 134-137: We also completed the Harper's forest map of year 1990 by filling unclassified areas (due to the presence of clouds on satellite images) using our forest cover map of year 2000. To do so, we assumed that if forest was present in 2000, the pixel was also forested in 1990. This procedure does not account for forest regeneration as you point out. However, it can also cause underestimations in deforestation between 1990-2000, as there might be more forest in the cloud gap in 1990 than there is in 2000 that is classified as non-forest.**

## Results:

**Line 262-265: Proportions of unclassified areas are not reported in the two other existing studies at the national level by MEFT et al. (2009) and ONE et al. (2015). With our approach, we produced wall-to-wall forest cover change maps from 1990 to 2014 for the full territory of Madagascar (Tab. 1). More suited for discussion...**

## Discussion:

**Line 348-359: There is ongoing scientific debate about the extent of the original" forest cover in Madagascar, and the extent to which humans have altered the natural forest landscapes since their large-scale settlement around 800 CE (Burns et al., 2016; Cox et al., 2012). Early French naturalists stated that the full island was originally covered by forest (Humbert, 1927; Perrier de La Bathie, 1921), leading to the common statement that 90% of the natural forests have disappeared since the arrival of humans on the island (Kull, 2000). More recent studies counter-balanced that point of view saying that extensive areas of grassland existed in Madagascar long before human arrival and were determined by climate, natural grazing and other natural factors (Virah-Sawmy, 2009; Vorontsova et al., 2016). Other authors have questioned the entire narrative of extensive alteration of the landscape by early human activity which, through legislation, has severe consequences on local people (Klein, 2002; Kull, 2000). Interesting to read but not very relevant for the discussion of the results.**

**Line 365-366: and Allnutt et al. (2008) estimated that deforestation between 1953 and 2000 led to an extinction of 9% of the species. Specify what group of species: invertebrates, plants, mammals, birds?**

# Answers to remarks by Reviewer 2

**The paper proposes an integrated approach to use existing datasets (national maps + global tree cover change) and produce robust forest change maps. The methods and tools used are free and open source and made public, which encourages replication and facilitates data sharing.** 

**The method is applied to Madagascar to produce long term estimation of forest cover change, and thus produces original data.**

We thank Reviewer 2 for pointing out the quality and originality of our results and the replicability of our research.

**Even though no proper accuracy assessment was done on the resulting maps, the subject is discussed in the paper and proxies are used to address the issue. It is an area of improvement acknowledged by the authors, that will need to be addressed for further updates of the map (with GFC 2015-2016 data for instance)**

We thank Reviewer 2 for his previous comments on the first version of the manuscript which have helped improve the discussion on the accuracy assessment of our results.

**This paper is of good quality and is recommended for publication, with one minor revision (Specific comment on tree cover threshold): please indicate in the paper what TC threshold would exactly match the forest area from the 2000 Harper map and compare with the 75% chosen from literature**

If a given tree cover threshold could allow to match the forest area in number of hectares, this threshold won't help to match the forest cover spatially. Some areas classified as forest in the 2000 Harper map would be considered as forest using the TC threshold, some not. As an alternative, we provide an additional figure representing the distribution of the tree cover values for all pixels considered as moist forest in the 2000 Harper map. On this figure, we show that choosing a threshold of 75% allows to identify most of the moist tropical forest without having to choose a lower threshold.

# Answers to remarks by Reviewer 3

**The paper submitted is a new version of the paper originally submitted by G. Vieilledent and colleagues in July 2017.**  

**The authors propose here a substantially improved and revised version of their former study. Such as in the original version, the paper studies long-term deforestation at national scale in Madagascar. On top of calculating updated values of forest cover and depicting fragmentation, the study proposes a methodology to compare and adapt past results/maps with today up-to-date data image processing. This is particularly interesting as it can serve as an example of workflow for developing countries that have often to deal with multiple reference data when it comes to monitor forest resources. Therefore, in addition of its direct value for Madagascar, the model-role that this study can play is very important for forest conservation in general (outside Madagascar). This might be a bit more highlighted in the Title and/or in the abstract.**

We have added a sentence in the abstract to underline the approach we have developped in Madagascar can be used in other tropical developing countries.

**Concerning my former remarks about fragmentation and the Riiters approach. The authors have now better defined what fragmentation is, they developed a better methodology to quantify it, and they developed a better discussion about the methods and the results. Abandoning the classical Riiters approach for a less disputable one (with a larger window and with clear bins of tree cover) is a clear improvement of the document. In that sense, I consider that my former main comments have been addressed.**

We thank Reviewer 3 for his comment on the first version of the manuscript which have helped improve the methodology used to compute forest fragmentation.

**As the authors mention some limitations about open forests, I suggest to read this recently published paper on open forest of Madagascar, that can provide additional information to complete their discussion:**

**de Haulleville et al. (2018). Fourteen years of anthropization dynamics in the Uapaca bojeri Baill. forest of Madagascar. Landscape and Ecological Engineering**

We thank Reviewer 3 for this reference.

**I thereby recommend the paper to be accepted for publication.**

# Answers to remarks by Reviewer 4

**This manuscript describes a process by which the authors have combined data on forest cover from multiple assessments based on remote sensing to quantify forest loss on Madagascar over 60 years.** 

**The benefits of and need for this study do need to be better articulated. The authors have presented figures but do not make any conservation / management recommendations from them. Thus, the study feels like a wasted opportunity at present. Identification, geographically, of the areas which have undergone the greatest loss would be useful (ie mention in text specific areas from the loss map). Also, some assessment as to loss protected areas could be undertaken. This need not be a detailed matching exercise to compare effectiveness, but simply quantification of their effectiveness, especially over time - are they increasingly important? This would make the study more applied.** 

**In terms of methods, combining land cover maps produced from remote sensing data by different methods is problematic. The errors are multiplicative. The authors have attempted to control for the different methods by a simple method but have not undertaken any accuracy assessment. I appreciate that each of the studies they use have undertaken their won accuracy assessments but I would like to have seen a dedicated assessment in this study. For example, cover at 500 control points stratified by forest / non forest in the latter time period could be examined from images back in time to assess visually forest  / non forest. These could then be linked to the forest cover maps. This would be very valuable in informing readers as to the accuracy of the combination process.**

**I have added multiple comments to the manuscript that I would like to see addressed. In particular, there is an early focus given to REDD+ but  but do not give this much more comment other than a passing mention in the discussion. The methods presented here are not really appropriate to REDD+ assessment so the authors need to either remove or re word these references.**

## Specific comments

**line 18: speculation, no analysis**

We have removed this sentence in the abstract but we have kept this statement for the discussion part.

**line 22: REDD+ does not need historical map so this is irrelevant**

We do not agree with that comment. REDD+ do need historical deforestation maps. The UNFCC REDD+ initiative aimed at Reducing Emissions from Deforestation and forest Degradation. To estimated the avoided deforestation, a baseline deforestation scenario need to be built. This baseline deforestation scenario relies on historical deforestation maps [@]

**line 40: Forests in general**

**line 67: This contradicts the earlier statement about no map available for post 2000**

**line 71: 2013 vs 2014 is one year**

**line 75: strange wording**

**line 81: Is a major issue not that each supervision algorithm differs and so there will be increasing inaccuracies.**

**line 111: No mention of redd here despite featureing in abstract**

**line 161: Explain that the method of Harper et al 2007 meant there were no isolated pixels**

**line 211: Capital F**

**line 219: What area is this?**

**line 220: How did this perform on coastal areas? Was sea masked or included?**

**line 233: Change or variation, not evolution.**

**line 235: This should be in discussion or in intorduction under a clear aims section**

**line 243: Reword**

**line 275: Variation**

**line 276: Delete everything before comma**

**line 299: "propose the use of.."**

**line 301: Any suggestions as to how many areas this might capture?**

**line 343: I don't see how this follow from the previous technical / ecological explanations.**

**line 361: Not actually true - you have shown forest loss has been severe but you have not shown it has been caused by human influence, nor that conservation activiteis have failed to halt it. It almost certainly has, and you are right o make the leap, but your results do not show it. A subtle but important point. Please re word this throughout**

**line 381: "supported by"**

**line 389: Can they? I thought FAO assessments have a very different protocol - please clarify**

**line 403: How can a study published in 2003 explain events post 2010? You need to expand more here.**

**legend of Table 1: “Change in”, not evolution**

# References