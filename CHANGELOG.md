# Changelog

## [1.3.0](https://github.com/ai4os/ai4os-hub-qa/compare/v1.2.0...v1.3.0) (2026-01-13)


### Features

* add 'Update Catalog page' stage ([#20](https://github.com/ai4os/ai4os-hub-qa/issues/20)) ([2e69599](https://github.com/ai4os/ai4os-hub-qa/commit/2e6959976b8fac887a8c9a61561db3dfd60f8416))
* Add check for the first commit ([6311f40](https://github.com/ai4os/ai4os-hub-qa/commit/6311f406b53bb79b75c7b66f4ee2714f113b473e))
* add env variable SQA_CONTAINER_NAME to sanitize BUILD_TAG ([780f399](https://github.com/ai4os/ai4os-hub-qa/commit/780f399cbe0c08ec0c7d5007c4ee93a974f34287))
* Add MIT License to the project ([552aaf5](https://github.com/ai4os/ai4os-hub-qa/commit/552aaf5cfee9c92771eabe97985824c974ee27cf))
* add provenance rebuild trigger ([#22](https://github.com/ai4os/ai4os-hub-qa/issues/22)) ([7b6cf67](https://github.com/ai4os/ai4os-hub-qa/commit/7b6cf67565324c1e4833438eae3cebc80dd11b55))
* add Zenodo DOI also to new metadata file if present ([ceab5d9](https://github.com/ai4os/ai4os-hub-qa/commit/ceab5d9cdbad3cfb97801511fe142664e9383021))
* add Zenodo DOI to all metadata files ([99bff23](https://github.com/ai4os/ai4os-hub-qa/commit/99bff2371acdee7b2120cf9308ae7432bec2e044))
* enable OSCAR notifications ([467fb26](https://github.com/ai4os/ai4os-hub-qa/commit/467fb26b5ff0f7ea9ea720ff53aa9a6caf0ab9eb))
* get Zenodo DOI, modify metadata and create PR ([fec6046](https://github.com/ai4os/ai4os-hub-qa/commit/fec6046fcfd00fdeb30bf9f45f111a7b8ba71cfd))
* initial Zenodo integration ([6e8d5de](https://github.com/ai4os/ai4os-hub-qa/commit/6e8d5dea5773f54a59affde53306336265071276))
* make metadata check mandatory even if module is not in the catalog ([e0460ee](https://github.com/ai4os/ai4os-hub-qa/commit/e0460eecf780625d01c7c2514d46c5d89202bc6c))
* remove support for old JSON metadata ([12d638f](https://github.com/ai4os/ai4os-hub-qa/commit/12d638f690774416f73b179f8ed88f2dcad7d93a))
* trigger latest release sync on first Zenodo+GitHub integration ([8a7a175](https://github.com/ai4os/ai4os-hub-qa/commit/8a7a175568324e1744780734bc574947d63b3a9b))
* update new PAPI refresh endpoint ([6aad905](https://github.com/ai4os/ai4os-hub-qa/commit/6aad9051782e500eeedcf6591efd178585d801e3))


### Bug Fixes

* cases when GIT_PREVIOUS_SUCCESSFUL_COMMIT fails ([798b9ef](https://github.com/ai4os/ai4os-hub-qa/commit/798b9efff75618ade164806d0040921b86b1d84c)), closes [#18](https://github.com/ai4os/ai4os-hub-qa/issues/18)
* check for modified files with previous success commit ([#17](https://github.com/ai4os/ai4os-hub-qa/issues/17)) ([47c704f](https://github.com/ai4os/ai4os-hub-qa/commit/47c704fae05c72d9a451188b0784eac256e4e5b7))
* check metadata.json only if present (not mandatory anymore) ([a16ae8a](https://github.com/ai4os/ai4os-hub-qa/commit/a16ae8a355440c601d2ef62002e702610a2eb0e5))
* correct typo in PR message ([84d51ff](https://github.com/ai4os/ai4os-hub-qa/commit/84d51ff10ca1699e55e371e77f0e072c858fc9b0))
* envar name ([4d3a27b](https://github.com/ai4os/ai4os-hub-qa/commit/4d3a27bc8259cca4ae16dbe2874ee7545c69fd74))
* error handling for changed_files check ([146525e](https://github.com/ai4os/ai4os-hub-qa/commit/146525ef14483859beefe5044113c6f89a1ca8f8))
* error handling for changed_files check ([d16590b](https://github.com/ai4os/ai4os-hub-qa/commit/d16590b25629ebf3867a6cfcd9a8ca53075e476e))
* erroring in the changed_files check ([7d2d928](https://github.com/ai4os/ai4os-hub-qa/commit/7d2d928fdfd3a478f87b7a7a03bcdfb35ecaa1b2))
* fetch master branch for OSCAR services ([64160ba](https://github.com/ai4os/ai4os-hub-qa/commit/64160bae27838cfde57e902f12469d02dcd62871))
* fetch master branch for OSCAR services update ([5a00fca](https://github.com/ai4os/ai4os-hub-qa/commit/5a00fca377d04885e135a6ab93834864b17b117a))
* how docker image name defined (temporary solution) ([325b993](https://github.com/ai4os/ai4os-hub-qa/commit/325b993fda15d97715c0ecf9252a73394ba6ea4e))
* how docker image name defined (temporary solution) ([508cb72](https://github.com/ai4os/ai4os-hub-qa/commit/508cb72f81d37e7a2617085f00d34a367898686b))
* improve Zenodo integration ([81d7e69](https://github.com/ai4os/ai4os-hub-qa/commit/81d7e69bc78d01a82b345cda8b0d48ee2e1461f9))
* improve Zenodo integration ([5461463](https://github.com/ai4os/ai4os-hub-qa/commit/5461463d4112d8dac0f19d5a7c54f4016a7d4719))
* pass SQA_CONTAINER_NAME to child job ([ef628c2](https://github.com/ai4os/ai4os-hub-qa/commit/ef628c23385db201171bddb11831e44e6fffb363))
* prettify JSON ([9cf0c28](https://github.com/ai4os/ai4os-hub-qa/commit/9cf0c289e301865021bb9d7919ccdef63d83bdf1))
* remove support for old JSON metadata ([5716c7e](https://github.com/ai4os/ai4os-hub-qa/commit/5716c7e334a7e095fead4705f6e31689f511158c))
* rename stages, fix broken stages ([4c90d2c](https://github.com/ai4os/ai4os-hub-qa/commit/4c90d2c6543b6a0e813fb6988ad738c07b6b2dd0))
* run OSCAR stage in Docker ([653eec3](https://github.com/ai4os/ai4os-hub-qa/commit/653eec323b120abeb65d92d56f5a99a65f0abbc7))
* setup env vars for script with folder properties ([75c7511](https://github.com/ai4os/ai4os-hub-qa/commit/75c75116193f1540c96d5fdcb4eeb41d2e1c2826))
* SQA_CONTAINER_NAME ([69a994d](https://github.com/ai4os/ai4os-hub-qa/commit/69a994d3cdf4104883857b35d1eacf56d36bfff4))
* SQA_CONTAINER_NAME definition ([91ea9a5](https://github.com/ai4os/ai4os-hub-qa/commit/91ea9a5304fd78e31820fc3733558a13aa1af1e3))
* stage name uniformity ([0a8b580](https://github.com/ai4os/ai4os-hub-qa/commit/0a8b580dad8c346f4524a150b300ccd8687042ca))
* typo in Jenkinsfile ([2b9517b](https://github.com/ai4os/ai4os-hub-qa/commit/2b9517bd40494dd6f4c84b7810334c734c3c7fdb))
* typo in Jenkinsfile ( ")" ) ([2b9517b](https://github.com/ai4os/ai4os-hub-qa/commit/2b9517bd40494dd6f4c84b7810334c734c3c7fdb))
* use correct credentials ([a516f2a](https://github.com/ai4os/ai4os-hub-qa/commit/a516f2aa43d1c3dd2c0a3273f7c4b00c54f734b3))
* use oscar-service-token credentials ([9a4cf8b](https://github.com/ai4os/ai4os-hub-qa/commit/9a4cf8b455d2bc30e4346954fda3da39e12e6f71))

## [1.2.0](https://github.com/ai4os/ai4os-hub-qa/compare/v1.1.0...v1.2.0) (2024-08-22)


### Features

* re-order stages, execute User tests for all repos ([c1b2c4f](https://github.com/ai4os/ai4os-hub-qa/commit/c1b2c4f937ab1f3721e3a783329e2700ba5e42c9))
* use ai4os CI images ([c224c83](https://github.com/ai4os/ai4os-hub-qa/commit/c224c83d212769f541c711d33da0b89007a507f5))
* when only metadata files have changed, run only metadata tests ([#11](https://github.com/ai4os/ai4os-hub-qa/issues/11)) ([840d6ff](https://github.com/ai4os/ai4os-hub-qa/commit/840d6ff19280f95d3aece1d8351fb2c2fd3100bf)), closes [#9](https://github.com/ai4os/ai4os-hub-qa/issues/9)


### Bug Fixes

* always execut rm -rf ai4os-hub-check-artifact ([e12f288](https://github.com/ai4os/ai4os-hub-qa/commit/e12f288b26847024b28cb1485a4b4bf1c8759260))
* in the Docker image build process, trying to take into account the current git branch ([b4e331f](https://github.com/ai4os/ai4os-hub-qa/commit/b4e331fd8da119b37d6a2fb70c20735ba66cb580))
* revert back order of stages; feat: read V1/V2 metadata for Docker image build ([bf7d083](https://github.com/ai4os/ai4os-hub-qa/commit/bf7d083b61d14ec4e53b5f0d1674b8acfd9bd426))

## [1.1.0](https://github.com/ai4os/ai4os-hub-qa/compare/1.0.0...v1.1.0) (2024-08-12)


### Features

* change order of tests ([036321f](https://github.com/ai4os/ai4os-hub-qa/commit/036321f61a7fb24151e1fc4ad98b8e05ca9f39b0))
* check for license existence ([00d04ce](https://github.com/ai4os/ai4os-hub-qa/commit/00d04ce77756f4ed1d462723a1592d77444a2feb))
* Check for V2 metadata ([029855f](https://github.com/ai4os/ai4os-hub-qa/commit/029855f55b3eccd7a3566dea9454ed424b147d31))
* do not use SQA tooling ([dfe44bb](https://github.com/ai4os/ai4os-hub-qa/commit/dfe44bb258a3df68f94789657b9c39fdfaad7e14))
* fail directly if metadata file not present ([dfad47f](https://github.com/ai4os/ai4os-hub-qa/commit/dfad47f08ff0444b6005fef29b07444b5e885b26))
* update OSCAR services ([3db8a90](https://github.com/ai4os/ai4os-hub-qa/commit/3db8a90f1335b85136937d59af88eb3e6f37fb5d))
* use parallel tests ([6ad7b1b](https://github.com/ai4os/ai4os-hub-qa/commit/6ad7b1b37433cabe2b41298365f86065db5794a9))


### Bug Fixes

* add OSCAR cluster before submitting ([80c1374](https://github.com/ai4os/ai4os-hub-qa/commit/80c137444cba0c5c9143127d2de5fddce8166527))
* always clean build ([7d8d58b](https://github.com/ai4os/ai4os-hub-qa/commit/7d8d58b9d314fd37a0363faa1c95d24ff8efe350))
* check for both YAML and JSON metadata files ([5876ec4](https://github.com/ai4os/ai4os-hub-qa/commit/5876ec44e9b443185b8e97a6a0927dd8db5559cd))
* do not use folder properties to store credentials ([0ed1ab3](https://github.com/ai4os/ai4os-hub-qa/commit/0ed1ab39abcfe3bca4bf4f98dd2c13fd3da72930))
* rename stages ([5c99c13](https://github.com/ai4os/ai4os-hub-qa/commit/5c99c13b946936dd07e59e1a4fcdd2899cd7074a))
* rename stages ([d1dc05f](https://github.com/ai4os/ai4os-hub-qa/commit/d1dc05fc3cf989489ef2fce8ed69d3de2bdf543d))
* skip OSCAR stage ([df0142b](https://github.com/ai4os/ai4os-hub-qa/commit/df0142b7d33dd3294fc3eba046f6990e6516e28d))
* skip stage if file not present ([0f2544f](https://github.com/ai4os/ai4os-hub-qa/commit/0f2544f6dfaf1ccd6321bfbfb8390cbd93eda96f))
* skip stage if no images to upload ([6e30f6e](https://github.com/ai4os/ai4os-hub-qa/commit/6e30f6e083235f2096e68e92186b7676e7e0c112))
* typo ([b20ea9b](https://github.com/ai4os/ai4os-hub-qa/commit/b20ea9b2df392b6edd7b9fa967d0b79149dee584))
* typo in parallel stage ([3b281c7](https://github.com/ai4os/ai4os-hub-qa/commit/3b281c725476fd8fe56e8b7d4389553ed0880fec))
* use ai4-metadata to check for both versions ([e69697d](https://github.com/ai4os/ai4os-hub-qa/commit/e69697dd03845d143aa5153573b72fdfaf597843))
* use correct path ([c56c680](https://github.com/ai4os/ai4os-hub-qa/commit/c56c680e3b28aab43a5d9bb2afcdcb26ece41276))
* use correct path ([9771763](https://github.com/ai4os/ai4os-hub-qa/commit/97717631848928366d25122813cbab8ebfb09da1))
* write JSON as a temporary file ([5189c52](https://github.com/ai4os/ai4os-hub-qa/commit/5189c52b3eff67540c10f6a630ca4970b8128cfa))
