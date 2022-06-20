---
layout:     post
title:      "Lustre에 대해 : 개요 및 특징"
date:       2022-06-xx
author:     권세훈 (qsh700@gluesys.com)
categories: blog
tags:       [Lustre, HPC, RDMA, Storage]
cover:      "/assets/[maincover image] "
main:       "/assets/[maincover image] "
---

# Lustre File System 소개

러스터(Lustre)는 병렬 분산 파일 시스템으로 주로 고성능 컴퓨팅의 대용량 파일 시스템으로 사용되고 있습니다. 
러스터(Lustre)의 이름은 Linux와 Cluster의 혼성어에서 유래됐습니다. 

러스터는 GNU GPL 정책의 일환으로 개방되어 있으며 소규모 클러스터 시스템부터 대규모 클러스터 시스템용 고성능 파일 시스템입니다. 

Lustre는 Linux 기반 운영체제에서 실행되며 클라이언트(Client)-서버(Server) 네트워크 아키텍처를 사용합니다.

# Lustre FS Architecture
![Alt text](/assets/Lustre_architecture.png)
<center>그림 1. Lustre Architecture</center>
&nbsp;

* MGS(Management Server)
  * 모든 Lustre 파일 시스템에 대한 구성 정보를 클러스터에 저장하고 이 정보를 다른 Lustre 호스트에 제공합니다.

* MGT(Management Target)
  * 모든 Lustre 노드에 대한 구성 정보는 MGS에 의해 MGT라는 저장 장치에 기록됩니다.

* MDS(Metadata Server)
  * Lustre 파일 시스템의 모든 네임 스페이스를 제공하여 파일 시스템의 아이노드(inodes)를 저장합니다. 
  * 파일 열기 및 닫기, 파일 삭제 및 이름 변경, 네임 스페이스 조작 관리를 합니다. 
  * Lustre 파일 시스템에서는 하나 이상의 MDS와 MDT가 존재합니다.

* MDT(Metadata Target)
  * MDS의 메타 데이터 정보를 지속적으로 유지하는데 사용되는 저장 장치입니다.

* OSS(Object Storage Servers)
  * 하나 이상의 로컬 OST에 대한 파일 I/O 서비스 및 네트워크 요청 처리를 제공합니다. 

* OST(Object Storage Target)
  * OSS 호스트에 고르게 분산되어 성능의 균형을 유지하고 처리량을 최대화합니다.

* Lustre clients
  * 각 클라이언트(client)는 여러 다른 Lustre 파일 시스템 인스턴스를 동시에 마운트 가능합니다.

* LNet(Lustre Networking)
  * 클라이언트가 파일 시스템에 액세스하는데 사용하는 고속 데이터 네트워크 프로토콜입니다.

# Lustre FS 특징 및 기능

* HSM(Hierarchical Storage Management)
  * HSM은 고가의 저장매체와 저가의 저장매체 간의 데이터를 자동으로 이동하는 데이터 저장 기술입니다.
  * HSM을 사용하면 다음과 같은 이점이 있습니다. 회사에서는 새 장비에 투자하지 않고도 이미 보유하고 있는 리소스를 최대한 활용할 수 있습니다. 또한, 가장 중요한 데이터의 운선 순위를 저장하여 고속 저장 장치의 공간을 확보합니다. 고속 저장 장치 보다 저속 저장 장치의 비용이 훨씬 저렴하기 때문에 스토리지 비용을 절감할 수 있습니다. 이는 기업에서 비용이 증가할 수 있는 대량의 데이터를 관리하는 경우에 특히 경제적입니다.
