MATLAB codes for the following manuscript (editorially accepted in PLoS Comput Biol on 23 May 2023)
Title: Opponent Learning with Different Representations in the Cortico-Basal Ganglia Pathways Can Develop Obsession-Compulsion Cycle
Authors: Reo Sato(#), Kanji Shimomura(#), & Kenji Morita(*) ((#):equal contribution, (*):corresponding author)


<Corresponding author of the manuscript>

Kenji Morita, Ph.D.   (ORCID iD: orcid.org/0000-0003-2192-4248)
Physical and Health Education, Graduate School of Education, The University of Tokyo
7-3-1 Hongo, Bunkyo-ku, Tokyo 113-0033, Japan
morita@p.u-tokyo.ac.jp


<Program code authors>

Reo Sato, Kenji Morita


<Usage of the codes>

- To generate the figures presented in the manuscript, run the codes in MATLAB in the corresponding "makeFig#.m" files
 (Note: For simulations of the two-stage task by our dual-system agents in Figures 6 and 9, we failed to save the seed for "randn" function used for generating reward probabilities. So please use the saved choice data .mat files to reproduce the figures.)

- Codes in R for statistical analysis are included in "makeFig6AB.m", "makeFig6CD.m", "makeFig6E.m", and "makeFig9B.m"

- To generate Q-learning versions of Figure 3 and Figure 4A,B,D,E, run the codes in MATLAB in the corresponding "Qlearning_version_of_makeFig#.m" files

- The three "makeFigF..." files include the codes for fitting of the data of Gillan et al. 2016 elife 5:e11305 (https://doi.org/10.7554/eLife.11305; obtained from https://osf.io/usdgt/) by our dual-system agent model, which we conducted but not included in the manuscript

- The other ".m" files are called in the files for making figures
