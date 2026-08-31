# Linux File Systems 

A **Linux file system** is a structured collection of files on a disk drive or a partition. A partition is a segment of memory/disk and contains some specific data.

Linux supports various file system types, such as ext4, XFS, Btrfs, and ZFS, each offering different features like journaling, scalability, and snapshot capabilities. The most commonly used file system on Linux is ext4, known for its balance between performance and reliability.

### **1. Directory Structure - Hierarchical Structure**

Linux uses a **hierarchical directory structure**, starting with the **root directory (`/`)** at the top. All files, directories, and devices are organized in this tree structure. Key directories include:

- **`/`**: Root directory (top-level directory).
- **`/bin`**: Essential binary executables for the system (e.g., `ls`, `cp`).
- **`/sbin`**: System binaries for system administration tasks.
- **`/etc`**: Configuration files for the system and services.
- **`/dev`**: Device files representing hardware components (e.g., disks, terminals).
- **`/home`**: Home directories for regular users (e.g., `/home/user1`).
- **`/root`**: Home directory for the root user.
- **`/var`**: Variable data, such as logs and spools.
- **`/tmp`**: Temporary files, usually cleared on reboot.
- **`/mnt`**: Mount points for temporarily mounted filesystems.
- **`/media`**: Mount points for removable media like CDs, USB drives.
- **`/lib`**: Shared libraries and kernel modules needed to boot the system.

### **2. Disk Management using LVM (Logical Volume Management)**

**LVM (Logical Volume Management)** allows for flexible disk management, enabling resizing of partitions and better use of disk space. It works by creating **Physical Volumes (PVs)**, **Volume Groups (VGs)**, and **Logical Volumes (LVs)**.

- **Physical Volume (PV)**: A physical device like a hard drive or partition (`/dev/sdb1`).
- **Volume Group (VG)**: A pool of storage created from one or more physical volumes. 
- **Logical Volume (LV)**: A virtual partition created from the space available in a volume group.

#### Basic LVM Commands:
- **Create a physical volume**:
  ```bash
  sudo pvcreate /dev/sdb
  ```
- **Create a volume group**:
  ```bash
  sudo vgcreate my_volume_group /dev/sdb
  ```
- **Create a logical volume**:
  ```bash
  sudo lvcreate -L 10G -n my_logical_volume my_volume_group
  ```
- **Extend a logical volume**:
  ```bash
  sudo lvextend -L +5G /dev/my_volume_group/my_logical_volume
  ```
- **Resize the filesystem**:
  ```bash
  sudo resize2fs /dev/my_volume_group/my_logical_volume
  ```

### **3. File CRUD Operations, File Copy (Local/Remote)**

**File CRUD Operations**:
- **Create**: `touch filename`, `mkdir directory`
- **Read**: `cat filename`, `less filename`
- **Update**: `nano filename`, `vim filename`
- **Delete**: `rm filename`, `rmdir directory`

#### **File Copy (Local/Remote)**:

- **Copy files locally**:
  ```bash
  cp source_file destination_file
  ```
  Use `-r` for copying directories:
  ```bash
  cp -r source_directory destination_directory
  ```

- **Copy files remotely using `scp` (Secure Copy)**:
  - Copy from local to remote:
    ```bash
    scp localfile username@remotehost:/path/to/destination
    ```
  - Copy from remote to local:
    ```bash
    scp username@remotehost:/path/to/remotefile /local/destination
    ```

- **Copy files using `rsync`** (efficient file transfer):
  - Local copy:
    ```bash
    rsync -av source_directory/ destination_directory/
    ```
  - Remote copy:
    ```bash
    rsync -av source_directory/ username@remotehost:/path/to/destination/
    ```

`rsync` is preferred for large data transfers due to its ability to resume interrupted transfers and only copy changed files.

### **4. File Permissions**

File permissions in Linux define what actions users can perform on files and directories. Permissions are categorized into **Read (r)**, **Write (w)**, and **Execute (x)** for **Owner**, **Group**, and **Others**.

#### Viewing File Permissions:
Use `ls -l` to view permissions:
```bash
ls -l filename
```
Example output:
```
-rwxr-xr-- 1 user1 group1 4096 Dec 21 16:30 index.html
```
- **`rwxr-xr--`**: Permissions for the file. 
  - Owner (`user1`) can read, write, and execute the file.
  - Group (`group1`) can read and execute the file.
  - Others can only read the file.

#### Modifying File Permissions:
- **Using `chmod` to change permissions**:
  - Grant read and write permissions to owner, and read-only permissions to others:
    ```bash
    chmod 644 filename
    ```
  - Add execute permission to owner:
    ```bash
    chmod u+x filename
    ```

- **Numeric Permission Representation**:
  - Permissions can also be set numerically, where:
    - `r = 4`, `w = 2`, `x = 1`.
    - Example: `chmod 755 file` (owner: read, write, execute; group and others: read, execute).

### **5. File Ownership**

Every file in Linux has an **owner** (user) and a **group** associated with it. The **owner** has control over the file, while the **group** can be granted specific permissions.

#### Viewing File Ownership:
Use `ls -l` to view the owner and group:
```bash
ls -l filename
```
Example output:
```
-rwxr-xr-- 1 user1 group1 4096 Dec 21 16:30 index.html
```
- **Owner**: `user1`
- **Group**: `group1`

#### Changing File Ownership:
- **Using `chown`** to change owner and group:
  - Change owner only:
    ```bash
    chown new_owner filename
    ```
  - Change owner and group:
    ```bash
    chown new_owner:new_group filename
    ```

#### Example:
Change the owner of `index.html` to `user2` and the group to `group2`:
```bash
chown user2:group2 index.html
```

-------------------------------------------------------------------------------------




