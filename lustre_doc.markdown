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

`러스터(Lustre)`는 병렬 분산 파일 시스템으로 주로 고성능 컴퓨팅의 대용량 파일 시스템으로 사용되고 있습니다. 
`러스터(Lustre)`의 이름은 `Linux`와 `Cluster`의 혼성어에서 유래됐습니다. 

러스터는 `GNU GPL` 정책의 일환으로 개방되어 있으며 소규모 클러스터 시스템부터 대규모 클러스터 시스템용 고성능 파일 시스템입니다. 

러스터는 `Linux` 기반 운영체제에서 실행되며 `클라이언트(Client)-서버(Server)` 네트워크 아키텍처를 사용합니다.

# Lustre FS Architecture
![Alt text](/assets/Lustre_architecture.png)
<center>그림 1. Lustre Architecture</center>

* MGS(Management Server)
  * 모든 러스터 파일 시스템에 대한 구성 정보를 클러스터에 저장하고 이 정보를 다른 `Lustre` 호스트에 제공합니다.

* MGT(Management Target)
  * 모든 러스터 노드에 대한 구성 정보는 `MGS`에 의해 `MGT`라는 저장 장치에 기록됩니다.

* MDS(Metadata Server)
  * 러스터 파일 시스템의 모든 네임 스페이스를 제공하여 파일 시스템의 `아이노드(inodes)`를 저장합니다. 
  * 파일 열기 및 닫기, 파일 삭제 및 이름 변경, 네임 스페이스 조작 관리를 합니다. 
  * 러스터 파일 시스템에서는 하나 이상의 `MDS`와 `MDT`가 존재합니다.

* MDT(Metadata Target)
  * `MDS`의 메타 데이터 정보를 지속적으로 유지하는데 사용되는 저장 장치입니다.

* OSS(Object Storage Servers)
  * 하나 이상의 로컬 `OST`에 대한 파일 I/O 서비스 및 네트워크 요청 처리를 제공합니다. 

* OST(Object Storage Target)
  * `OSS` 호스트에 고르게 분산되어 성능의 균형을 유지하고 처리량을 최대화합니다.

* Lustre clients
  * 각 `클라이언트(client)`는 여러 다른 러스터 파일 시스템 인스턴스를 동시에 마운트 가능합니다.

* LNet(Lustre Networking)
  * 클라이언트가 파일 시스템에 액세스하는데 사용하는 고속 데이터 네트워크 프로토콜입니다.

# Lustre FS 특징 및 기능

* HSM(Hierarchical Storage Management)
  * `HSM`은 고가의 저장매체와 저가의 저장매체 간의 데이터를 자동으로 이동하는 데이터 저장 기술입니다.

`HSM`을 사용하면 다음과 같은 이점이 있습니다. 회사에서는 새 장비에 투자하지 않고도 이미 보유하고 있는 리소스를 최대한 활용할 수 있습니다. 또한, 가장 중요한 데이터의 운선 순위를 저장하여 고속 저장 장치의 공간을 확보합니다. 고속 저장 장치 보다 저속 저장 장치의 비용이 훨씬 저렴하기 때문에 스토리지 비용을 절감할 수 있습니다. 이는 기업에서 비용이 증가할 수 있는 대량의 데이터를 관리하는 경우에 특히 경제적입니다.

* HSM Architecture

![HSM](/assets/HSM_architecture.png)
<center>그림 2. HSM Architecture</center>

  * 러스터 파일 시스템을 하나 이상의 외부 스토리지 시스템에 연결할 수 있습니다.
  * 파일을 읽기, 쓰기, 수정과 같이 파일에 접근하게되면 `HSM` 스토리지에서 러스터 파일 시스템으로 파일을 다시 가져옵니다.
  * 파일을 `HSM` 스토리지에 복사하는 프로세스를 `아카이브(Archive)`라고 하고 아카이브가 완료되면 러스터 파일 시스템에 존재하는 데이터를 삭제할 수 있습니다. 이것을 `Release`라고 말합니다. `HSM`스토리지에서 러스터 파일 시스템으로 데이터를 반환하는 프로세스를 `restore`라고 합니다. 여기서 말하는 restore와 archive는 `HSM Agent`라는 데몬이 필요합니다.
  * `에이전트(Agent)`는 `coopytool`이라는 유저 프로세스가 실행되어 러스터 파일 시스템과 `HSM`간의 파일 아카이브 및 복원을 관리합니다.
  * `코디네이터(Coordinator)`는 러스터 파일 시스템을 `HSM` 시스템에 바인딩하려면 각 파일 시스템 `MDT`에서 코디네이터가 활성화되어야 합니다.

* HSM과 러스터 파일 시스템간의 데이터 관리 유형은 5가지의 요청으로 이루어집니다.
  * archive : 러스터 파일 시스템 파일에서 `HSM` 솔루션으로 데이터를 복사합니다.
  * release : 러스터 파일 시스템에서 파일 데이터를 제거합니다.
  * restore : `HSM` 솔루션에서 해당 러스터 파일 시스템으로 파일 데이터를 다시 복사합니다.
  * remove : `HSM` 솔루션에서 데이터 사본을 삭제합니다.
  * cancel : 진행 중이거나 보류 중인 요청을 삭제합니다.

* PCC(Persistent Client Cache)


![pcc](/assets/pcc.png)
<center>그림 3. pcc</center>


`PCC`는 러스터 클라이언트 측에서 로컬 캐시 그룹을 제공하는 프레임워크입니다. 각 클라이언트는 `OST`대신 로컬 저장 장치를 자체 캐시로 사용합니다. 로컬 파일 시스템은 로컬 저장장치 안에 있는 캐시 데이터를 관리하는데 사용됩니다. 캐시된 I/O의 경우 로컬 파일 시스템으로 전달되어 처리되고 일반 I/O는 OST로 전달됩니다.

`PCC`는 데이터 동기화를 위해 `HSM` 기술을 사용합니다. `HSM copytool`을 사용하여 로컬 캐시에서 `OST`로 파일을 복원합니다. 각 `PCC`에는 고유한 아카이브 번호로 실행되는 copytool 인스턴스가 있고 다른 러스터 클라이언트에서 접근하게되면 데이터 동기화가 진행됩니다. `PCC`가 있는 클라이언트가 오프라인될 시 캐시된 데이터는 일시적으로 다른 클라이언트에서 접근할 수 없게 됩니다. 이후 `PCC`클라이언트가 재부팅되고 `copytool`이 다시 동작하면 캐시 데이터에 다시 접근할 수 있습니다.

* PCC 이점
 
클라이언트에서 로컬 저장장치를 캐시로 이용하게 되면 네트워크 지연이 없고 다른 클라이언트에 대한 오버헤드가 없습니다. 또한, 로컬 저장장치를 I/O 속도가 빠른 `SSD` or `NVMe SSD`를 통해 좋은 성능을 낼 수 있습니다. `SSD`는 모든 종류의 `SSD`를 캐시 장치로 이용할 수 있습니다. `PCC`를 통해 작거나 임의의 I/O를 `OST`로 저장할 필요 없이 로컬 캐시 장치에 저장하여 사용하면 `OST`의 부담을 줄일 수 장점이 있습니다.

* OverStriping

![OVERSTRIPING](/assets/overstriping.png)
<center>그림 4. overstriping</center>

오버스트라이핑(overstriping)은 기존에 `OST`당 하나였던 `stripe`를 여러개의 `stripe`를 가질 수 있게 만든것 입니다. 기본적으로 스트라이프의 크기는 1M(1048576byte)로 되어있습니다.

일반적으로 러스터에서는 스트라이프를 구성하기 전 순차적으로 `OST`에 저장되는것을 확인할 수 있습니다. `stripe`를 구성 후 에는 각 `OST`마다 동등하게 분배되어 파일이 저장되는것을 확인할 수 있습니다. 오버스트라이핑 같은 경우 일반 스트라이핑으로 구성한 것 보다 빠르다는 장점이 있습니다.

  * 다음은 일반 스트라이핑 구성과 오버스트라이핑을 구성하는 명령어입니다.
```console
//Client에서 실행
# lfs setstripe --stripe-count 4 [filename] //OST가 4개일 때 4개의 스트라이프
# lfs setstripe --overstripe-count 8 [filename] //OST가 4개일 때 8개의 스트라이프

//stripe 구성 확인
# lfs getstripe [filename]
```

* DOM(Data-ON-MDT)
