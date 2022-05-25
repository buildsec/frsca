workspace {

    model {
        developer = person "Developer"
        frsca = softwareSystem "Secure Software Factory" {
            config = container "Config" {
                ssf_defaults = component "FRSCA Defaults"
                organization = component "Organization Config"
                team = component "Team Config"
                project = component "Project Config"

                security = component "Security Policy Config"
                infrastructure = component "Infrastructure Policy Config"
            }

            ssf_defaults -> organization "Constrains"
            organization -> team "Constrains"
            team -> project "Constrains"

            security -> organization "Enforces Policy"
            security -> team "Enforces Policy"
            security -> project "Enforces Policy"
            
            infrastructure -> organization "Enforces Policy"
            infrastructure -> team "Enforces Policy"
            infrastructure -> project "Enforces Policy"
            
            code = container "FRSCA Structure" {
                ssf_tooling = component "FRSCA Tooling"
                ssf_library = component "FRSCA CUE Library"
                user_configuration = component "End User Configuration"
                kubernetes = group "Kubernetes" {
                    tekton_pipelines = component "Tekton Pipelines"
                    tekton_chains = component "Tekton Chains"
                    kyverno = component "Kyverno"
                    k8s = component "Other resources"
                }
            }
            
            op = group "Scheduling and Orchestration Platform" {
                pipeline = container "Pipeline Framework and Tooling"
                build_environment = container "Build Environment(s)" {
                    fetch_code = component "Fetch Code/Dependencies Task"
                    pre_build_tasks = component "Pre-build Task(s)"
                    build_artefact = component "Build Artefact Task"
                    post_build_tasks = component "Post-build Task(s)"
                    publish_artefact = component "Publish Artefact Task"

                    storage = component "Runtime Build Storage"

                    fetch_code -> pre_build_tasks
                    fetch_code -> storage "Copies code to"
                    pre_build_tasks -> build_artefact
                    pre_build_tasks -> storage "Reads code from"
                    build_artefact -> post_build_tasks
                    build_artefact -> storage "Reads code from/Writes artefact(s) to"
                    post_build_tasks -> publish_artefact
                    post_build_tasks -> storage "Reads artefact(s) from"
                    publish_artefact -> storage "Reads artefact(s) from"
                }
                node_attestor = container "Node Attestor"
                workload_attestor = container "Workload Attestor"
                pipeline_observer = container "Pipeline Observer"
                admission_controller = container "Admission Controller"
                runtime_visibility = container "Runtime Visibility"
            }

            pmf = container "Policy Management Framework"
            metadata_storage = container "Metadata Storage"
        }

        scr = softwareSystem "Source Code Control" {
            tags "External"
        }

        artefact_storage = softwareSystem "Artefact Storage" {
            tags "External"
        }

        prod = softwareSystem "Production Environment" {
            tags "External"
        }

        prod_admission_controller = softwareSystem "Production Admission Controller" {
            tags "External"
        }

        identity_services = softwareSystem "Identity Services" {
            tags "External"

            user_iam = container "User IAM"
            service_identity = container "Service Identity"
        }



        developer -> frsca "Gets feedback from"
        developer -> scr "Pushes code to"
        
        frsca -> scr "Pulls code from"
        frsca -> artefact_storage "Pushes artefacts to/Pulls dependencies from"

        service_identity -> workload_attestor "Provides identities to"
        service_identity -> node_attestor "Provides identities to"
        service_identity -> pipeline_observer "Provides identity to"

        identity_services -> frsca "Provides identities to"
        identity_services -> developer "Provides identity to"

        pipeline -> build_environment "Manages tasks in"
        node_attestor -> build_environment "Validates identity of build nodes"
        pipeline_observer -> build_environment "Tracks task runs in"
        pipeline_observer -> node_attestor "Includes node identity info from"
        pipeline_observer -> workload_attestor "Includes workload identity info from"
        workload_attestor -> build_environment "Validates identity of task workloads"
        admission_controller -> build_environment "Enforces admission policy on task workloads"
        admission_controller -> pipeline "Enforces orchestration of valid pipeline framework"
        admission_controller -> pmf "Uses policies from"
        admission_controller -> metadata_storage "Uses signatures and attestions from"
        runtime_visibility -> build_environment "Detects malicious or anomalous behaviour in"
        build_environment -> scr "Pulls code from"
        build_environment -> artefact_storage "Pushes artefacts to/Pulls dependencies from"
        pipeline_observer -> metadata_storage "Pushes attestations and signatures to"

        fetch_code -> scr "Fetches code from"
        fetch_code -> artefact_storage "Fetches dependencies from"
        publish_artefact -> artefact_storage "Pushes artefact(s) to"

        pre_build_tasks -> metadata_storage "Pushes attestations to"
        build_artefact -> metadata_storage "Pushes attestations to"
        post_build_tasks -> metadata_storage "Pushes attestations to"

        pipeline_observer -> fetch_code "Records task info"
        pipeline_observer -> pre_build_tasks "Records task info"
        pipeline_observer -> build_artefact "Records task info"
        pipeline_observer -> post_build_tasks "Records task info"
        pipeline_observer -> publish_artefact "Records task info"

        prod_admission_controller -> prod "Enforces signature and attestation policy"
        prod -> artefact_storage "Runs artefacts from"

        ssf_tooling -> user_configuration "Uses"
        user_configuration -> ssf_library "Inherits"
        ssf_tooling -> tekton_pipelines "Deploys tasks and pipelines"
        ssf_tooling -> tekton_chains "Deploys resources and configuration"
        ssf_tooling -> kyverno "Deploys policies"
        ssf_tooling -> k8s "Deploys config maps, secrets, etc."

        tekton_pipelines -> artefact_storage "Pushes images to"
        tekton_chains -> artefact_storage "Pushes attestations to"
        tekton_chains -> tekton_pipelines "Records builds"
        kyverno -> tekton_pipelines "Enforces policy on"
        kyverno -> k8s "Enforces Policy on"
    }

    views {
        systemLandscape frsca "Diagram4" {
            include *
        }

        systemContext frsca "Diagram1" {
            include *
        }

        container frsca "Diagram2" {
            include *
        }

        component build_environment "Diagram3" {
            include *
        }

        component config "Diagram4" {
            include *
        }

        component code "Diagram5" {
            include *
        }

        styles {
            element "External" {
                background #A9A9A9
            }

            element "Element" {
                fontSize 30
            }

            relationship "Relationship" {
                fontSize 32
                colour #000000
                width 250
            }
        }

        theme default
    }

}
