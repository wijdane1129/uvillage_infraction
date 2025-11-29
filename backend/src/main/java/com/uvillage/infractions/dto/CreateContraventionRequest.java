package com.uvillage.infractions.dto;

import java.util.List;

public class CreateContraventionRequest {
    private String description;
    private String typeLabel; // label of ContraventionType
    private Long userAuthorId;
    private Long tiersId; // optional resident id
    private List<String> mediaUrls;

    public CreateContraventionRequest() {}

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTypeLabel() { return typeLabel; }
    public void setTypeLabel(String typeLabel) { this.typeLabel = typeLabel; }

    public Long getUserAuthorId() { return userAuthorId; }
    public void setUserAuthorId(Long userAuthorId) { this.userAuthorId = userAuthorId; }

    public Long getTiersId() { return tiersId; }
    public void setTiersId(Long tiersId) { this.tiersId = tiersId; }

    public List<String> getMediaUrls() { return mediaUrls; }
    public void setMediaUrls(List<String> mediaUrls) { this.mediaUrls = mediaUrls; }
}
