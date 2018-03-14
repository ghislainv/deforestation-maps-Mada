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

Please find enclosed a new version of our article untitled "Combining global tree cover loss data with historical national forest cover maps to look at six decades of deforestation and forest fragmentation in Madagascar". We thank the four Reviewers for their careful reading of our manuscript and their many insightful remarks. We made our best to answer to Reviewers' comments and we modified our manuscript accordingly. We really hope that you will find this new version of our article suitable for publication in _Biological Conservation_.

Best regards,

The authors

# Answers to remarks by Reviewer 1

**Dear authors,**

**In your manuscript "Combining global tree cover loss data with historical national forest cover maps to look at six decades of deforestation and forest fragmentation in Madagascar", you combine two existing forest cover change products (from Harper et al. 2007 and Hansen et al. 2013) to study forest cover change and forest fragmentation on Madagascar between 1953 and 2014. The national product of Harper et al. (2007) provides the earliest estimation of forest cover and is based on the interpretation of aerial photography (1953) and the supervised classification of Landsat satellite images (1973, 1990, 2000). The recent annual estimates of forest cover (2000-2014) are derived from the global product of Hansen et al. (2013) and are also based on a supervised classification of Landsat images. In this study,  the two products were combined using resampling techniques and the gaps in the Harper et al. (2007) 2000 map caused by cloud cover were filled by assigning areas covered by forest in the 2000 map of Hansen et al. (2013) as forest. Similarly, gaps in the Harper et al. (2007) 1990 and 1973 maps were filled by the newly developed gap filled 2000 and 1990 forest cover maps, respectively. Forest cover change was estimated from these newly computed forest cover maps for four ecoregions (moist forest, dry forest, spiny forest and mangrove). In addition, two metrics of forest fragmentation were computed: the density of forest pixels in the neighborhood of a forest pixel (using a moving window) and distance to the forest edge.**

**Your results show a significant decline in natural forest cover on Madagascar, with an initial increase in the deforestation rate (1953 -- 1990), a subsequent decline (1990-2005) and a recent increase of the deforestation rate from 2005 to 2014. The early deforestation estimates were similar to those of Harper et al. (2007), although there were some differences due to the delineation of the ecoregions. The deforestation estimates for recent year (2005-2014) were significantly lower compared to those provided by ONE (2015). However, the trends found in this study are similar to those reported is the previous studies. With deforestation, the fragmentation of the remaining forest increased over the years. Possible limitations are discussed concerning the accuracy of the classification of forest/non-forest, that depend on the accuracy of the used products. Furthermore, you discuss the implications of the observed deforestation for the conservation of species confined to these forests and potential socio-economic drivers of deforestation on Madagascar.**

## General impression

**I have enjoyed reading the manuscript as it is well written and the study presents interesting findings. The ongoing deforestation of Madagascar's natural forest is certainly a subject worthy of investigation and relevant to policy makers in Madagascar, to NGO's and scientists studying nature conservation, tropical ecology, land use change, rural development etc. However, I have some concerns about the advances made in this manuscript compared to previous studies and the lack of validation of the forest/non-forest classification. In the manuscript, two existing forest cover products are combined to study forest cover change in an extended period of time. The techniques used to combine the products and to fill cloud cover gaps are well established and there is no validation of the newly developed forest cover maps, not by field measurements (ground truth) and neither by other means (e.g. high resolution aerial photography, above ground biomass maps, lidar data). That the deforestation trend found here corresponds closely to the trend reported in previous studies should therefore be no surprise, as roughly the same data and analysis were used. While the socio-economic drivers of the observed deforestation and the implications for the biodiversity of Madagascar are shortly discussed, additional information about these drivers and implications that would enhance the impact of the manuscript are not presented. Extending the period of forest cover change and analyzing trends in deforestation on Madagascar is a relevant scientific exercise, but without additional validation or secondary data, this manuscript is presently not suited for an international journal in the discipline of conservation biology.**

## Specific comments

**Introduction: Clear and concise, interesting to read**

Thanks for that positive comment.

**Line 38-40: Tropical forests in Madagascar also store a large amount of carbon (Vieilledent et al., 2016) and high rates of deforestation in Madagascar are responsible for large CO2 emissions in the atmosphere (Achard et al.,41 2014). Quantify large, high, etc., also in line 48: "Much lower"**

**Methodology: In the introduction the limitations of the products from Hansen et al. (2013) and Harper et al. (2007) are pointed out (e.g. cloud gaps, the delineation of ecoregions, plantations are classified as forest regrowth) so why would you combine these two products?**

The two products are complementary. Harper et al. provide forest cover maps for Madagascar, but these maps are 1) not free of clouds, and 2) only available up to year 2000. On the contrary, Hansen et al. provide tree cover products without forest definition but which are 1) free of clouds and 2) available on a recent period from 2000 to 2014. Combining the two products allows to obtain recent cloud-free forest cover change maps at the national scale for Madagascar on the period 2000-2014.

**Why not start over from the beginning using "raw" Landsat data freely available online and use a single supervised classification method and training dataset. This would reduce the uncertainties related to differences between data products in tree cover/forest definitions, training data, map projection, etc.**

One aim of our study is precisely to propose an alternative approach to the classical supervised classification method of Landsat satellite images based on a training data-set. As underline in the introduction of the article:

"the production of such forest maps from a supervised classification approach requires significant resources, especially regarding the image selection step (required to minimize cloud cover) and the training step (visual interpretation of a large number of polygons needed to train the classification algorithm) (Rakotomalalaet al. 2015). Most of this work of image selection and visual interpretation would need to be repeated to produce new forest maps in the future using a similar approach". 

This is especially true when the objective is to obtain a forest cover change map at large geographical scale, for example the national scale for Madagascar. Our approach is much simpler, relies on already available data-sets and can be used to produce new forest cover change maps in the future as soon as the global tree cover loss product is updated.

**Line 134-137: We also completed the Harper's forest map of year 1990 by filling unclassified areas (due to the presence of clouds on satellite images) using our forest cover map of year 2000. To do so, we assumed that if forest was present in 2000, the pixel was also forested in 1990. This procedure does not account for forest regeneration as you point out. However, it can also cause underestimations in deforestation between 1990-2000, as there might be more forest in the cloud gap in 1990 than there is in 2000 that is classified as non-forest.**

## Results:

**Line 262-265: Proportions of unclassified areas are not reported in the two other existing studies at the national level by MEFT et al. (2009) and ONE et al. (2015). With our approach, we produced wall-to-wall forest cover change maps from 1990 to 2014 for the full territory of Madagascar (Tab. 1). More suited for discussion...**

We understand this remark by Reviewer 1. We agree that comparison with previous studies should usually be done in the discussion part. In our case, the comparison with previous studies form a specific part of the Method section (see sub-section 2.3 untitled "Comparing our forest cover and deforestation rate estimates with previous studies"). As a consequence, sub-section 3.2 untitled "Comparison with previous forest cover change studies in Madagascar" in the Result part presents the results associated to these comparison between studies. In the Discussion part, we preferred to focus on 1) the advantages and uncertainties associated to our approach, 2) 

## Discussion:

**Line 348-359: There is ongoing scientific debate about the extent of the "original" forest cover in Madagascar, and the extent to which humans have altered the natural forest landscapes since their large-scale settlement around 800 CE (Burns et al., 2016; Cox et al., 2012). Early French naturalists stated that the full island was originally covered by forest (Humbert, 1927; Perrier de La Bathie, 1921), leading to the common statement that 90% of the natural forests have disappeared since the arrival of humans on the island (Kull, 2000). More recent studies counter-balanced that point of view saying that extensive areas of grassland existed in Madagascar long before human arrival and were determined by climate, natural grazing and other natural factors (Virah-Sawmy, 2009; Vorontsova et al., 2016). Other authors have questioned the entire narrative of extensive alteration of the landscape by early human activity which, through legislation, has severe consequences on local people (Klein, 2002; Kull, 2000). Interesting to read but not very relevant for the discussion of the results.**

We do not agree with the Reviewer 1 on this point. Our study can contribute to this debate which has implications on the conservation strategies adopted at the country level. Our results show that Madagascar has lost 44% of its natural forest cover over the period 1953-2014. The direct causes of deforestation are attributable to human activities such as slash-and-burn agriculture and pasture [@Scale2011]. As a consequence, it is difficult to question the entire narrative of extensive alteration of the landscape by early human activity [@Klein2002; @Kull2000]. Our results demonstrate that human activities since the 1950s have profoundly impacted the natural tropical forests and that conservation and development programs in Madagascar have failed to stop deforestation in the recent years. We think this is an important point to address in the discussion, in particular for a journal such as _Biological Conservation_ which publishes studies aiming at advancing natural resource management and conservation policy.

**Line 365-366: and Allnutt et al. (2008) estimated that deforestation between 1953 and 2000 led to an extinction of 9% of the species. Specify what group of species: invertebrates, plants, mammals, birds?**

We specified: "Based on occurrence data for 2243 species of plants and invertebrates, Allnutt et al. (2008) estimated that deforestation between 1953 and 2000 has led to an extinction of 9% of the species."

# Answers to remarks by Reviewer 2

**The paper proposes an integrated approach to use existing datasets (national maps + global tree cover change) and produce robust forest change maps. The methods and tools used are free and open source and made public, which encourages replication and facilitates data sharing.** 

**The method is applied to Madagascar to produce long term estimation of forest cover change, and thus produces original data.**

We thank Reviewer 2 for pointing out the quality and originality of our results and the replicability of our research.

**Even though no proper accuracy assessment was done on the resulting maps, the subject is discussed in the paper and proxies are used to address the issue. It is an area of improvement acknowledged by the authors, that will need to be addressed for further updates of the map (with GFC 2015-2016 data for instance)**

We thank Reviewer 2 for his previous comments on the first version of the manuscript which have helped improve the discussion on the accuracy assessment of our results.

**This paper is of good quality and is recommended for publication, with one minor revision (Specific comment on tree cover threshold): please indicate in the paper what TC threshold would exactly match the forest area from the 2000 Harper map and compare with the 75% chosen from literature**

If a given tree cover threshold could allow to match the forest area in number of hectares, this threshold won't help to match the forest cover spatially. Some areas classified as forest in the 2000 Harper map would be considered as forest using this TC threshold, some not. As an alternative, we provide an additional figure in Supplementary Material (Fig. A1) representing the percentage of moist forest having a tree cover superior to a given value. On this figure, we show that 90% of the moist forest in 2000 has a tree cover greater or equal to 75%.

# Answers to remarks by Reviewer 3

**The paper submitted is a new version of the paper originally submitted by G. Vieilledent and colleagues in July 2017.**  

**The authors propose here a substantially improved and revised version of their former study. Such as in the original version, the paper studies long-term deforestation at national scale in Madagascar. On top of calculating updated values of forest cover and depicting fragmentation, the study proposes a methodology to compare and adapt past results/maps with today up-to-date data image processing. This is particularly interesting as it can serve as an example of workflow for developing countries that have often to deal with multiple reference data when it comes to monitor forest resources. Therefore, in addition of its direct value for Madagascar, the model-role that this study can play is very important for forest conservation in general (outside Madagascar). This might be a bit more highlighted in the Title and/or in the abstract.**

We have added a sentence in the abstract to underline that the approach we have developped in Madagascar can be used in other developing countries with tropical forest.

**Concerning my former remarks about fragmentation and the Riiters approach. The authors have now better defined what fragmentation is, they developed a better methodology to quantify it, and they developed a better discussion about the methods and the results. Abandoning the classical Riiters approach for a less disputable one (with a larger window and with clear bins of tree cover) is a clear improvement of the document. In that sense, I consider that my former main comments have been addressed.**

We thank Reviewer 3 for his comment on the first version of the manuscript which have helped improve the methodology used to compute forest fragmentation.

**As the authors mention some limitations about open forests, I suggest to read this recently published paper on open forest of Madagascar, that can provide additional information to complete their discussion:**

**de Haulleville et al. (2018). Fourteen years of anthropization dynamics in the Uapaca bojeri Baill. forest of Madagascar. Landscape and Ecological Engineering**

We thank Reviewer 3 for this reference. We have read it but we found it difficult to add it to the reference list.

**I thereby recommend the paper to be accepted for publication.**

# Answers to remarks by Reviewer 4

**This manuscript describes a process by which the authors have combined data on forest cover from multiple assessments based on remote sensing to quantify forest loss on Madagascar over 60 years.** 

**The benefits of and need for this study do need to be better articulated. The authors have presented figures but do not make any conservation / management recommendations from them. Thus, the study feels like a wasted opportunity at present. Identification, geographically, of the areas which have undergone the greatest loss would be useful (ie mention in text specific areas from the loss map). Also, some assessment as to loss protected areas could be undertaken. This need not be a detailed matching exercise to compare effectiveness, but simply quantification of their effectiveness, especially over time - are they increasingly important? This would make the study more applied.**

We now mention in the results the areas which have undergone the greatest loss in the Result part:

"The forest cover change map produced on the period 1953-2014 (Fig. 2) allows to identify hot-spots of deforestation. Among the many recent hot-spots of deforestation visible on the map for the period 2000-2014 , one is located at the south of the CAZ (_"Corridor Ankeniheny Zahamena"_) protected area, in the moist forest at the east of Madagascar (see eastern zoom in Fig. 2). Another major hot-spot of deforestation is located around the Ranobe-PK32 new protected area, in the dry forest at the south-west of Madagascar (see western zoom in Fig. 2)."

Assessing the effectiveness of the protected area network in curbing deforestation is out of the scope of this study. This assessment will be done in a future study. 

**In terms of methods, combining land cover maps produced from remote sensing data by different methods is problematic. The errors are multiplicative. The authors have attempted to control for the different methods by a simple method but have not undertaken any accuracy assessment. I appreciate that each of the studies they use have undertaken their own accuracy assessments but I would like to have seen a dedicated assessment in this study. For example, cover at 500 control points stratified by forest / non forest in the latter time period could be examined from images back in time to assess visually forest  / non forest. These could then be linked to the forest cover maps. This would be very valuable in informing readers as to the accuracy of the combination process.**

The same remark was made by Review 2 in the first round of review. We copy here our answer which has been accepted by Reviewer 2:

A whole paragraph (section 4.1) now discuss the accuracy of our results. In particular, we recognize that a proper accuracy assessment of our forest cover change maps should be performed to better estimate the uncertainty surrounding our forest cover change estimates in Madagascar from year 2000 [@Olofsson2013; @Olofsson2014]. Collecting enough suitable data, using for example the results of the photo-interpretation of very high resolution satellite images as ground "truth", would require a large amout of additional work and is out of the scope of our study. In place, we decided to report the results of previous studies regarding the accuracy of Hansen's tree cover loss data in Sub-Saharian Africa [@Verhegghen2016; @Tyukavina2015]. In particular, we report the large amount of false-negatives (non-detected deforestation) in the tree cover loss product and discuss this limitation:

"In another study assessing the accuracy of the tree cover loss product accross the tropics [@Tyukavina2015], authors reported 4% of false positives and 48% of false negatives in Sub-Saharian Africa. They showed that 85% of missing loss occured on the edges of other loss patches. This means that tree cover loss might be underestimated in Sub-Saharian Africa, probably due to the prevalence of small-scale disturbance which is hard to map at 30 m, but that areas of large-scale deforestation are well identified and spatial variability of the deforestation is well represented."

**I have added multiple comments to the manuscript that I would like to see addressed. In particular, there is an early focus given to REDD+ but  but do not give this much more comment other than a passing mention in the discussion. The methods presented here are not really appropriate to REDD+ assessment so the authors need to either remove or re word these references.**

We answer to each of the specific comment below. In particular, we answer to the point arguing that the method presented here is not appropriate for implementing REDD+.

## Specific comments

**line 18: speculation, no analysis**

We have removed this sentence in the abstract but we have kept this statement for the discussion part.

**line 22: REDD+ does not need historical map so this is irrelevant**

We do not agree with that comment. The UNFCCC REDD+ aims at Reducing Emissions from Deforestation and forest Degradation. REDD+ do need historical deforestation maps. To estimated the avoided deforestation, a baseline deforestation scenario need to be built. This baseline deforestation scenario relies on historical deforestation maps [@Olander2008]. Our forest cover change map can be used at the regional scale for pilot REDD+ project [@Vieilledent2013] or at the national scale to build a baseline deforestation scenario and estimate the associated CO$_2$ emissions.

**line 40: Forests in general**

Because we are focused on Madagascar in this study we kept this formulation. As suggested by Reviewer 1 we provided numbers to be more specific. 

**line 67: This contradicts the earlier statement about no map available for post 2000**

The earlier statement was that: "accurate and exhaustive forest cover maps are not available for Madagascar after year 2000". More recent map have been produced but we explain in the rest of the paragraph why these map are not accurate or not exhaustive. 

**line 71: 2013 vs 2014 is one year**

Here we do not say that the forest-cover change maps over the periods 2005-2010-2013 by @ONE2015 are too old in comparison with our maps. We underline the fact that these maps shows large mis-classification in specific areas and that production of such forest maps from a supervised classification approach requires a significant amount of resources compared to our approach combining historical forest cover maps and recent tree cover loss.

**line 75: strange wording**

We rephrase the sentence: "especially in the dry and spiny forest domain for which the spectral signal shows strong seasonal variations due to the deciduousness of such forests"

**line 81: Is a major issue not that each supervision algorithm differs and so there will be increasing inaccuracies.**

We are not sure to have clearly understood this comment by Reviewer 4. Here we just underline the fact that our approach combining available historical forest cover maps and recent tree cover loss data to derive a forest cover change map is simpler than approaches based on the semi-supervised classification of satellite images. Using our approach, new forest cover change maps can be produced as soon as the global tree cover loss product is updated. 

**line 111: No mention of redd here despite featureing in abstract**

We prefer to stay general in the introduction. Application to REDD+ is mentioned in the discussion:

"Current rates of deforestation can also be used to build reference scenarios for deforestation in Madagascar and contribute to the implementation
of deforestation mitigation activities in the framework of REDD+ [@Olander2008]."

**line 161: Explain that the method of Harper et al 2007 meant there were no isolated pixels**

Isolated non-forest pixels might have been present in Harper's maps, except for the 1953 forest map which is a vector map produced by scanning the paper map of Humbert et al. (1965) which was derived from the visual interpretation of aerial photographies. We corrected all the maps from year 1973.

**line 211: Capital F**

Corrected.

**line 219: What area is this?**

We added the area: "We used a moving window of 51 x 51 pixels (corresponding to an area of about 2.34 km2) centered on each forest pixel to compute the percentage of forest pixels in the neighborhood."

**line 220: How did this perform on coastal areas? Was sea masked or included?**

We added a specification in the text: "Water bodies were not masked when computing the percentage of forest pixels, meaning that forest located near a water body was considered as fragmented". This methodological choice does not impact our results as we are focused on the change of forest fragmentation over time (see Tab. 4).

**line 233: Change or variation, not evolution.**

Corrected.

**line 235: This should be in discussion or in intorduction under a clear aims section**

There is a whole part in the introduction on the impact of forest fragmentation on species conservation and carbon stocks: 

"Forest fragmentation can also lead to species extinction by isolating populations from each other and creating forest patches too small to maintain viable populations (Saunders et al., 1991). Fragmentation also increases forest edge where ecological conditions (such as air temperature, light intensity and air moisture) can be dramatically modified, with consequences on the abundance and distribution of species (Broadbent et al., 2008; Gibson et al., 2013; Murcia, 1995). Forest fragmentation can also have substantial effects on forest carbon storage capacity, as carbon stocks are much lower at the forest edge than under a closed canopy (Brinck et al. 2017)."

We found more appropriate to specify the distance within which micro-habitat are altered in the methodological part of the article. This to justify our choice of estimating the amount of forest within a distance of 100 m from forest edge. The references cited in the methodological part on this point are also present in the introduction.

**line 243: Reword**

We replaced the sentence by: "Madagascar has lost 44% of its natural forest between 1953 and 2014, including 37% between 1973 and 2014 (Fig. 2 and Tab. 1)."

**line 275: Variation**

Corrected

**line 276: Delete everything before comma**

Done.

**line 299: "propose the use of.."**

Corrected.

**line 301: Any suggestions as to how many areas this might capture?**



**line 343: I don't see how this follow from the previous technical / ecological explanations.**

The statement that "young secondary forests provide more limited ecosystem services compared to old-growth natural forests in terms of biodiversity and carbon storage" does not follow from the previous technical/ecological explanations. It comes in addition to the two previous statement: young forest regrowths are 1) rare, 2) easilly reburnt, and 3) of less ecological value than old growth forests. We added a reference [@Martin2013] supporting this last statement.

**line 361: Not actually true - you have shown forest loss has been severe but you have not shown it has been caused by human influence, nor that conservation activities have failed to halt it. It almost certainly has, and you are right to make the leap, but your results do not show it. A subtle but important point. Please reword this throughout**

There is no debate on the direct causes of the deforestation in Madagascar, which is associated to human activities such as slash-and-burn agriculture and pasture [@Scales2011]. The debate is about the original forest cover and about the extent to which humans have altered the natural forest landscapes since their large-scale settlement around 800 CE. We added a sentence and a reference to be clearer:

"We estimated that natural forest in Madagascar covers 8.9 Mha in 2014 (corresponding to 15% of the country) and that Madagascar has lost
44% of its natural forest since 1953 (37% since 1973). If there are no doubts about the direct causes of deforestation in Madagascar, attributable to human activities such as slash-and-burn agriculture and pasture (Scales, 2011), there is ongoing scientific debate about the extent of the ``original'' forest cover in Madagascar, and the extent to which humans have altered the natural forest landscapes since their large-scale settlement around 800 CE   (Burns et al., 2016; Cox et al., 2012.)."

**line 381: "supported by"**

Corrected.

**line 389: Can they? I thought FAO assessments have a very different protocol - please clarify**

We confirm that our estimates of forest cover and deforestation rates can be used as source of information for the next FAO Forest Resources Assessment (FRA) report. The FRA report is based on two primary sources of data: Country Reports prepared by National Correspondents and remote sensing that is conducted by FAO together with national focal points and regional partners (http://www.fao.org/forest-resources-assessment/background/en/). Country Reports can be based on different sources of information, such as national forest inventories or remote sensing studies. For example, Madagascar 2015 FRA report (http://www.fao.org/3/a-az264f.pdf) is partly based on the remote sensing studies by @MEFT2009, @ONE2013, and @ONE2015.

**line 403: How can a study published in 2003 explain events post 2010? You need to expand more here.**

**legend of Table 1: "Change in", not evolution**

Corrected.

# References