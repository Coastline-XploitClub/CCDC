import json
import boto3
from termcolor import colored


def main() -> None:
    while True:
        session: boto3.Session = boto3.Session(region_name="us-west-2")
        ec2: boto3.client = session.client("ec2")
        response = ec2.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        instances = response["Reservations"]
        print("\nWelcome to the EC2 Monitoring script")
        print("Please select from an option below to continue:\n\n")
        print("1. Print all running instance information")
        print("2. Print specific instance information given an instance ID")
        print("3. Terminate an instance by ID")
        print("4. Launch a new instance from a template")
        print("5. Exit")
        print()
        choice: str = input("Enter your option (1-5): ")
        try:
            choice = int(choice)
            if choice == 1:
                print_instances(instances)
            elif choice == 2:
                instance_id: str = input("Enter the instance ID: ")
                print_instance(instances, instance_id)
            elif choice == 3:
                instance_id = input("Enter the instance ID: ")
                terminate_instance(instance_id)
            elif choice == 4:
                launch_instance()
            elif choice == 5:
                print("Exiting program")
                break
            else:
                print(
                    "Invalid option selected.\
                        Please enter a number between 1 and 5."
                )
        except ValueError:
            print(
                "Invalid option selected.\
                    Please enter a number between 1 and 5."
            )


def print_instances(instances) -> None:
    instance_full_list = []
    for reservation in instances:
        for instance in reservation["Instances"]:
            instance_id: json = instance["InstanceId"]
            instance_type: json = instance["InstanceType"]
            instance_image_id: json = instance["ImageId"]
            instance_key_name: json = instance["KeyName"]
            instance_security_groups: json = instance["SecurityGroups"]
            instance_vpc_id: json = instance["VpcId"]
            instance_subnet_id: json = instance["SubnetId"]
            instance_launch_time: json = instance["LaunchTime"]
            instance_tags: json = instance.get("Tags", [])
            print(
                colored(
                    "\n\nInstance Information",
                    "cyan",
                    attrs=["reverse", "bold"],
                )
            )
            print(
                colored("Instance ID: ", "yellow", attrs=["bold"]),
                instance_id,
            )
            print(
                colored("Instance Type: ", "yellow", attrs=["bold"]),
                instance_type,
            )
            print(
                colored("Instance Image ID: ", "yellow", attrs=["bold"]),
                instance_image_id,
            )
            print(
                colored("Instance Key Name: ", "yellow", attrs=["bold"]),
                instance_key_name,
            )
            print(
                colored(
                    "Instance Security Groups: ",
                    "yellow",
                    attrs=["bold"],
                ),
                instance_security_groups,
            )
            print(
                colored("Instance VPC ID: ", "yellow", attrs=["bold"]),
                instance_vpc_id,
            )
            print(
                colored("Instance Subnet ID: ", "yellow", attrs=["bold"]),
                instance_subnet_id,
            )
            print(
                colored(
                    "Instance Launch Time: ",
                    "yellow",
                    attrs=["bold"],
                ),
                instance_launch_time,
            )
            print(
                colored("Instance Tags: ", "yellow", attrs=["bold"]),
                instance_tags,
            )
            instance_full_list.append(instance_tags)

    short_instance_list = [
        [dict["Value"] for dict in instances if dict["Key"] == "Name"]
        + [instance["InstanceId"]]
        for instances in instance_full_list
        if any(dict["Key"] == "Name" for dict in instances)
    ]
    print(colored("\n\nShort instance list\n", "blue", attrs=["reverse", "bold"]))
    for instance in short_instance_list:
        print(
            colored(f"{instance}", "blue", attrs=["reverse", "bold", "reverse", "bold"])
        )

    print(
        colored(
            f"\nCount: {len(short_instance_list)} ", "blue", attrs=["reverse", "bold"]
        ),
    )


def print_instance(instances, instance_id) -> None:
    for reservation in instances:
        for instance in reservation["Instances"]:
            if instance["InstanceId"] == instance_id:
                print(
                    f"{colored('Instance ID: ', 'blue', attrs=['reverse','bold'])}{instance['InstanceId']}"
                )
                print(
                    f"{colored('Instance Type: ', 'blue', attrs=['reverse','bold'])}{instance['InstanceType']}"
                )
                print(
                    f"{colored('Instance Image ID: ', 'blue', attrs=['reverse','bold'])}{instance['ImageId']}"
                )
                print(
                    f"{colored('Instance Key Name: ', 'blue', attrs=['reverse','bold'])}{instance['KeyName']}"
                )
                print(
                    f"{colored('Instance Security Groups: ', 'blue', attrs=['reverse','bold'])}{instance['SecurityGroups']}"
                )
                print(
                    f"{colored('Instance VPC ID: ', 'blue', attrs=['reverse','bold'])}{instance['VpcId']}"
                )
                print(
                    f"{colored('Instance Subnet ID: ', 'blue', attrs=['reverse','bold'])}{instance['SubnetId']}"
                )
                print(
                    f"{colored('Instance Launch Time: ', 'blue', attrs=['reverse','bold'])}{instance['LaunchTime']}"
                )
                print(
                    f"{colored('Instance Tags: ', 'blue', attrs=['reverse','bold'])}{instance['Tags']}"
                )
                print()
                return
    print(
        f"{colored('Instance ID not found: ', 'red', attrs=['reverse','bold'])}{instance_id}"
    )


def terminate_instance(instance_id) -> None:
    ec2: boto3.client = boto3.client("ec2")
    try:
        # Check if the instance exists
        ec2.describe_instances(InstanceIds=[instance_id])
    except ec2.exceptions.ClientError as e:
        # Handle non-existent instances
        if e.response["Error"]["Code"] == "InvalidInstanceID.NotFound":
            print(f"\nInstance with ID {instance_id} not found.\n\n")
            return
        else:
            raise e

    # Confirm before deletion
    confirm: str = input(
        f"\nAre you sure you want to terminate instance {instance_id}? (y/n) \n"
    )
    if confirm.lower() != "y":
        print(f"\nInstance {instance_id} not terminated.\n\n")
        return

    # Terminate the instance
    ec2.terminate_instances(InstanceIds=[instance_id])
    print(f"\nInstance {instance_id} terminated.\n\n")


def launch_instance() -> None:
    try:
        ec2: boto3.client = boto3.client("ec2")
        template_id = "lt-0ee6177a356c96858"
        name_tag_value = input("\nEnter the name of your new Kali instance: ")

        response: ec2.instance = ec2.run_instances(
            LaunchTemplate={"LaunchTemplateId": template_id},
            MinCount=1,
            MaxCount=1,
            TagSpecifications=[
                {
                    "ResourceType": "instance",
                    "Tags": [
                        {"Key": "Name", "Value": name_tag_value},
                    ],
                },
            ],
        )

        instance_id: json = response["Instances"][0]["InstanceId"]
        print(
            f"\nSuccessfully launched instance with ID {instance_id} and Name {name_tag_value}\n\n"
        )
    except Exception as e:
        print(f"\n\nThe following error occurred when launching instance: {e}\n\n")


if __name__ == "__main__":
    main()
