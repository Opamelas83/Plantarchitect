non_replicated_trials <- MyArchidata %>%
  filter(!is.na(replicate)) %>%
  count(studyName, replicate) %>%
  summarise(n=length(studyName), n1 = max(replicate)) %>%
  filter(n1==1) %>%
  dplyr::select(studyName)

non <- MyArchidata %>%
  filter(!is.na(studyName))%>%
  group_by(studyName, germplasmName) %>%
  summarise(n = length(germplasmName))

nons <- MyArchidata %>%
  filter(!is.na(studyName))%>%
  group_by(studyName) %>%
  summarise(n = length(germplasmName))

